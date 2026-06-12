############################################
# IAM Role for AWS Config
############################################

resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "config_policy" {
  name = "aws-config-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}",
          "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}/config/*"
        ]
      },
      {
        Sid    = "AWSConfigKMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RetireGrant"
        ]
        Resource = aws_kms_key.phi_cmk.arn
      },
      {
        Sid    = "AWSConfigDescribe"
        Effect = "Allow"
        Action = [
          "config:Describe*",
          "config:Get*",
          "config:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# Configuration Recorder
############################################

resource "aws_config_configuration_recorder" "recorder" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

############################################
# Delivery Channel
############################################

resource "aws_config_delivery_channel" "channel" {
  name           = "default"
  s3_bucket_name = data.aws_s3_bucket.evidence_vault.bucket
  s3_key_prefix  = "config"
  s3_kms_key_arn = aws_kms_key.phi_cmk.arn
  sns_topic_arn  = null

  depends_on = [
    aws_config_configuration_recorder.recorder
  ]
}

############################################
# Start the Recorder
############################################

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.channel
  ]
}

############################################
# Example AWS Config Rule
############################################

resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.recorder_status
  ]
}
