package compliance.hipaa.lambda_vpc

# METADATA
# title: HIPAA — Lambda functions must run inside a VPC
# custom:
#   framework: hipaa
#   controls:
#     - "164.312(c)(1)"
#   severity: high

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "aws_lambda_function"

  rc.change.after.vpc_config == null

  msg := sprintf("Lambda function %v must run inside a VPC", [rc.address])
}
