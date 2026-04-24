
variable "allowed_ips" {
    type      =list (string)
    sensitive = true
    

}




variable "email" {
    description ="Email address for CloudWatch alarm notifications"
    type        = string
    sensitive   = true
}

variable "aws_region" {
    description = "AWS region for resource deployment"
    type        = string
    default     ="us-east-1"

}

variable "ssh_key_name" {
    description = "Name of SSH key pair for EC2 instances"
    type        = string
    sensitive   = true
    default     = "jonnys-hub-key-new"

}

variable "project_name" {
    description ="Project name prefix for resource naming"
    type        = string
    default     = "jonnys"
}

#CIDR block variables

variable "hub_vpc_cidr" {
  description = "CIDR block for Hub VPC"
  type        = string
  sensitive   = true
}

variable "hub_public_subnet_cidr" {
  description = "CIDR block for Hub public subnet"
  type        = string
  sensitive   = true
}

variable "hub_private_subnet_cidr"{
    description = "CIDR block for Hub private subnet"
    type        = string
    sensitive   = true
}

variable "novastream_vpc_cidr" {
  description = "CIDR block for NovaStream VPC"
  type        = string
  sensitive   = true
}

variable "novastream_private_subnet_cidr" {
  description = "CIDR block for NovaStream private subnet"
  type        = string
  sensitive   = true
}

variable "healthcare_vpc_cidr" {
  description = "CIDR block for Healthcare VPC"
  type        = string
  sensitive   = true
}

variable "healthcare_private_subnet_cidr" {
  description = "CIDR block for Healthcare private subnet"
  type        = string
  sensitive   = true
}

