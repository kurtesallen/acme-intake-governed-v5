package hipaa.s3_tls_test

import data.hipaa.s3_tls

test_s3_tls_enabled {
  s3_tls.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "encryption_in_transit": true
    }
  }
}

test_s3_tls_disabled {
  not s3_tls.allow with input as {
    "resource_type": "aws_s3_bucket",
    "data": {
      "encryption_in_transit": false
    }
  }
}
