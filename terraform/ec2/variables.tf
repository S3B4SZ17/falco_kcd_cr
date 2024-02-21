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
