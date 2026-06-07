package hipaa.s3_encryption_test

import data.hipaa.s3_encryption

test_s3_encryption_enabled {
  s3_encryption.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "server_side_encryption": true
    }
  }
}

test_s3_encryption_disabled {
  not s3_encryption.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "server_side_encryption": false
    }
  }
}
