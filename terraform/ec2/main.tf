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

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = ">= 2.0.0, < 3.0.0"
  
  key_name_prefix    = "minikube"
  create_private_key = true
  tags = local.tags
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon-linux.id
  instance_type               = "c5.xlarge"
  key_name                    = module.key_pair.key_pair_name
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

resource "null_resource" "provision-files" {

  depends_on = [
    aws_instance.ec2_instance,
    module.key_pair
  ]

  triggers = {
    # Use the ec2 instance_id as a unique identifier to trigger file provisioning
    version = aws_instance.ec2_instance.id
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = module.key_pair.private_key_openssh
    host        = aws_instance.ec2_instance.public_ip
  }

  #Provision falco-values.yaml
  provisioner "file" {
    source      = templatefile("${path.module}/files/values.yaml", {
      aws_region          = var.aws_region,
      aws_access_key      = var.aws_access_key,
      aws_secret_access_key = var.aws_secret_access_key,
      github_repos        = var.github_repos,
      aws_instance_ip     = aws_instance.ec2_instance.public_ip,
      github_plugin_token = var.github_plugin_token,
    })
    destination = "/home/ec2-user/values.yaml"
  }

  #Provision initialization script
  provisioner "file" {
    source      = "${path.module}/files/k8s.sh"
    destination = "/home/ec2-user/k8s.sh"
  }

  # Running the initialization script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/k8s.sh",
      "/home/ec2-user/k8s.sh"
    ]
  }
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
