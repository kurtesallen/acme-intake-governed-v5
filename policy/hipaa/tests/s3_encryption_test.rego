package hipaa.s3_encryption_test

import data.hipaa.s3_encryption

test_deny_unencrypted_bucket {
  msg := s3_encryption.deny[_] with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_server_side_encryption_configuration",
        "address": "aws_s3_bucket_server_side_encryption_configuration.example",
        "change": {
          "after": {
            "rule": [
              {
                "apply_server_side_encryption_by_default": {
                  "sse_algorithm": "AES256"
                }
              }
            ]
          }
        }
      }
    ]
  }

  msg == "S3 bucket aws_s3_bucket_server_side_encryption_configuration.example must use SSE-KMS encryption"
}

test_allow_encrypted_bucket {
  not deny_exists with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_server_side_encryption_configuration",
        "address": "aws_s3_bucket_server_side_encryption_configuration.example",
        "change": {
          "after": {
            "rule": [
              {
                "apply_server_side_encryption_by_default": {
                  "sse_algorithm": "aws:kms"
                }
              }
            ]
          }
        }
      }
    ]
  }
}

deny_exists {
  _ := s3_encryption.deny[_]
}
