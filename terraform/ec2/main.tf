locals {
  tags = {
    Environment = "dev"
    Project     = "falco-sec"
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon-linux.id
  instance_type               = "c5.xlarge"
  vpc_security_group_ids      = [module.vpc.default_security_group_id, aws_security_group.ssh_access.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  # iam_instance_profile        = aws_iam_instance_profile.falco-sec.name

  user_data_base64 = base64encode(templatefile("${path.module}/files/overall-setup.sh", {
  }))
  user_data_replace_on_change = true

  tags     = local.tags
  tags_all = local.tags
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240131.0-x86_64-gp2"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "falco-sec"
  cidr = var.cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  tags = local.tags
}

resource "aws_security_group" "ssh_access" {
  vpc_id      = module.vpc.vpc_id
  name_prefix = "falco-sec-access-rules"

  #SSH For EC2 provisioner and troubleshooting
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    description = "SSH access"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    description = "HTTP access"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    description = "Outbound traffic to the internet"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
