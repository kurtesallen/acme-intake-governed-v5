package hipaa.s3_tls_test

import data.compliance.hipaa.s3_tls

test_deny_insecure_transport {
  msgs := s3_tls.deny with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_policy",
        "address": "aws_s3_bucket_policy.example",
        "change": {
          "after": {
            "Statement": [
              {
                "Condition": {
                  "Bool": {
                    "aws:SecureTransport": "false"
                  }
                }
              }
            ]
          }
        }
      }
    ]
  }

  count(msgs) > 0
}

test_allow_secure_transport {
  msgs := s3_tls.deny with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_policy",
        "address": "aws_s3_bucket_policy.example",
        "change": {
          "after": {
            "Statement": [
              {
                "Condition": {
                  "Bool": {
                    "aws:SecureTransport": "true"
                  }
                }
              }
            ]
          }
        }
      }
    ]
  }

  count(msgs) == 0
}
