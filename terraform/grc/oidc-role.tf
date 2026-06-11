############################################
# GitHub OIDC Provider
############################################

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

############################################
# IAM Role for GitHub GRC Gate
############################################

resource "aws_iam_role" "github_grc_role" {
  name = "acme-github-grc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # --- GitHub OIDC trust ---
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:kurtesallen/acme-intake-governed-v5:*"
          }
        }
      },

      # --- Static IAM user fallback trust (with TagSession) ---
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::846470648858:user/kurt"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

############################################
# IAM Policy for GitHub GRC Gate
############################################

resource "aws_iam_role_policy" "github_grc_policy" {
  role = aws_iam_role.github_grc_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Sign",
          "kms:DescribeKey",
          "kms:GetPublicKey"
        ]
        Resource = aws_kms_key.phi_cmk.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${data.aws_s3_bucket.evidence_vault.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformStateLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:846470648858:table/acme-terraform-locks"
      }
    ]
  })
}
