# AWS region
variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
  default     = "us-east-1"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet CIDR Block
variable "subnet_cidr_block" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# EC2 instance type
variable "instance_type_nginx" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}

# variable "instance_type_jenkins" {
#   description = "The instance type for the EC2 instance."
#   type        = string
#   default     = "t2.medium"
# }

# AMI ID
variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0e86e20dae9224db8"  # Ubuntu AMI
}
