variable "s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

variable "name" {
  type        = string
  default     = "falco-sec"
  description = "The prefix name for all the resources of the module"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the module resources"
  default = {
    "project" = "falco"
  }
}
