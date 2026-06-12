resource "aws_sns_topic" "hipaa_alerts" {
  name = "hipaa-detection-alerts"
}

resource "aws_iam_role" "lambda_detection_role" {
  name = "hipaa-detection-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_detection_policy" {
  role = aws_iam_role.lambda_detection_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketEncryption",
          "s3:GetBucketVersioning",
          "s3:GetBucketPolicyStatus"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.hipaa_alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "hipaa_detection" {
  function_name = "hipaa-s3-detection"
  role          = aws_iam_role.lambda_detection_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  filename = "${path.module}/lambda/hipaa_detection.zip"
}

resource "aws_cloudwatch_event_rule" "s3_create" {
  name        = "detect-s3-creation"
  description = "Detect new S3 buckets for HIPAA compliance"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventName" : ["CreateBucket"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_create.name
  target_id = "hipaa-detection"
  arn       = aws_lambda_function.hipaa_detection.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hipaa_detection.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_create.arn
}
