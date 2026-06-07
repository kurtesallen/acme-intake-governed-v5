resource "aws_kms_key" "phi_cmk" {
  description             = "HIPAA PHI CMK for DynamoDB, S3, and evidence signing"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ---------------------------------------------------------
      # 1. Allow root account full control (required)
      # ---------------------------------------------------------
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      # ---------------------------------------------------------
      # 2. Allow AWS Config to encrypt evidence into S3
      # ---------------------------------------------------------
      {
        Sid    = "AllowAWSConfigUseOfTheKey"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      # ---------------------------------------------------------
      # 3. Allow CloudTrail to encrypt logs (required for your setup)
      # ---------------------------------------------------------
      {
        Sid    = "AllowCloudTrailUseOfTheKey"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      # ---------------------------------------------------------
      # 4. Allow your GitHub OIDC role to decrypt/encrypt evidence
      # ---------------------------------------------------------
      {
        Sid    = "AllowGithubRoleUse"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.github_grc_role.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Purpose   = "phi-encryption"
    ManagedBy = "terraform"
  }
}
