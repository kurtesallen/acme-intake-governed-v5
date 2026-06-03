package hipaa.s3_versioning_test

import data.compliance.hipaa.s3_versioning

test_deny_unversioned_bucket {
  msgs := s3_versioning.deny with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_versioning",
        "address": "aws_s3_bucket_versioning.example",
        "change": {
          "after": {
            "versioning_configuration": {
              "status": "Suspended"
            }
          }
        }
      }
    ]
  }

  count(msgs) > 0
}

test_allow_versioned_bucket {
  msgs := s3_versioning.deny with input as {
    "resource_changes": [
      {
        "type": "aws_s3_bucket_versioning",
        "address": "aws_s3_bucket_versioning.example",
        "change": {
          "after": {
            "versioning_configuration": {
              "status": "Enabled"
            }
          }
        }
      }
    ]
  }

  count(msgs) == 0
}
