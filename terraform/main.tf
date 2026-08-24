provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
locals {
  application_subnet_id = sort(data.aws_subnets.default.ids)[0]
}

data "aws_route_table" "application" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = data.aws_route_table.application.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.default.id
}

data "aws_key_pair" "deployment" {
  key_name = var.key_name
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-"
  description = "HTTP access for the app and SSH access for deployment"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.project_name}-web"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  # Port 80 is public because Nginx is the entry point for the app.
  #checkov:skip=CKV_AWS_260:The app needs a public HTTP endpoint.
  security_group_id = aws_security_group.web.id
  description       = "Public traffic to Nginx"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from the current GitHub runner"
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Download system packages over HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.web.id
  description       = "Download packages and dependencies over HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_instance" "application" {
  # The project uses a public address because there is no load balancer or private runner.
  #checkov:skip=CKV_AWS_88:A public address is needed for deployment and browser access.
  # Basic monitoring is enough for this small, short-lived server.
  #checkov:skip=CKV_AWS_126:Detailed monitoring would add cost without helping this project.
  # t2.micro is enough for the app and does not support EBS optimisation.
  #checkov:skip=CKV_AWS_135:EBS optimisation is not available on t2.micro.
  # The app does not call AWS services, so it does not need an IAM role.
  #checkov:skip=CKV2_AWS_41:An instance role would provide access the app does not use.
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.deployment.key_name
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  monitoring                  = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted             = true
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp3"
  }

  tags = {
    Name = var.project_name
  }

  volume_tags = {
    Name = "${var.project_name}-root"
  }
}
