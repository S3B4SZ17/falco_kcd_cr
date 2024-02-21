variable "private_subnets" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "List of private subnets"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.1.4.0/24", "10.1.5.0/24"]
  description = "List of public subnets"
}

variable "cidr" {
  description = "CIDR Block definition"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "github_plugin_token" {
  description = "GitHub plugin token"
  type        = string
  sensitive   = true
}

variable "github_repos" {
  description = "GitHub repositoryies separated by comma, if multiple"
  type        = string
  default     = "S3B4SZ17/falco_kcd_cr"
}
