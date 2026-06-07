package hipaa.s3_versioning_test

import data.hipaa.s3_versioning

test_s3_versioning_enabled {
  s3_versioning.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "versioning_enabled": true
    }
  }
}

test_s3_versioning_disabled {
  not s3_versioning.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "versioning_enabled": false
    }
  }
}
