terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=2.1"
    }
  }
}
