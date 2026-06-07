############################################
# Evidence Vault Bucket Policy (CloudTrail + AWS Config)
############################################

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "evidence_vault_policy" {

  ############################################
  # CloudTrail Permissions
  ############################################

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}"
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  ############################################
  # AWS Config Permissions
  ############################################

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}"
    ]
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.evidence_vault.id}/config/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "evidence_vault_policy" {
  bucket = data.aws_s3_bucket.evidence_vault.id
  policy = data.aws_iam_policy_document.evidence_vault_policy.json
}
