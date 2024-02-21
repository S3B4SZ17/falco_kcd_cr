config {

}

plugin "aws" {
    enabled = true
    version = "0.28.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
    enabled = true
    version = "0.25.1"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
    enabled = true
    version = "0.26.0"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Project",
    "ManagedBy",
  ]
}
