module "falcosecurity_for_cloud_aws_single_account" {
  source = "github.com/falcosecurity/falco-aws-terraform//examples/single-account?ref=main"
  name   = var.name
}

output "cloudtrail_sns_subscribed_sqs_url" {
  value       = module.falcosecurity_for_cloud_aws_single_account.cloudtrail_sns_subscribed_sqs_url
  description = "URL of the cloudtrail-sns subscribed sqs"
}

output "cloudtrail_sns_subscribed_sqs_arn" {
  value       = module.falcosecurity_for_cloud_aws_single_account.cloudtrail_sns_subscribed_sqs_arn
  description = "ARN of the cloudtrail-sns subscribed sqs"
}
