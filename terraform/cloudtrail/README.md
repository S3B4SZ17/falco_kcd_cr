# cloudtrail

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

No providers.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.25.0 |

## Usage

The basic usage of this module is as follows:

```hcl
module "example" {
	 source  = "<module-path>"

	 # Optional variables
	 name  = "falco-sec"
	 tags  = {
  "Environment": "dev",
  "ManagedBy": "Terraform",
  "Project": "falco-sec"
}
}
```

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The prefix name for all the resources of the module | `string` | `"falco-sec"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the module resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "falco-sec"<br>}</pre> | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_falcosecurity_for_cloud_aws_single_account"></a> [falcosecurity\_for\_cloud\_aws\_single\_account](#module\_falcosecurity\_for\_cloud\_aws\_single\_account) | github.com/falcosecurity/falco-aws-terraform//examples/single-account | main |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_sns_subscribed_sqs_arn"></a> [cloudtrail\_sns\_subscribed\_sqs\_arn](#output\_cloudtrail\_sns\_subscribed\_sqs\_arn) | ARN of the cloudtrail-sns subscribed sqs |
| <a name="output_cloudtrail_sns_subscribed_sqs_url"></a> [cloudtrail\_sns\_subscribed\_sqs\_url](#output\_cloudtrail\_sns\_subscribed\_sqs\_url) | URL of the cloudtrail-sns subscribed sqs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
