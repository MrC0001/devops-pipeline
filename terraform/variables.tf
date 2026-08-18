variable "aws_region" {
  description = "AWS region used by the project."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region, for example us-east-1."
  }
}

variable "project_name" {
  description = "Name used for the AWS resources."
  type        = string
  default     = "devops-pipeline"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.project_name))
    error_message = "project_name must contain 3 to 32 lowercase letters, numbers, or hyphens."
  }
}

variable "instance_type" {
  description = "EC2 instance type used to run the app."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair used for SSH."
  type        = string
}

variable "ssh_cidr" {
  description = "Single IPv4 address allowed to connect over SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && endswith(var.ssh_cidr, "/32")
    error_message = "ssh_cidr must be a single IPv4 address using a /32 suffix."
  }
}
