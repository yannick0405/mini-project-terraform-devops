variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "shared_credentials_file" {
  description = "Path to AWS shared credentials file"
  type        = string
  default     = "../../.secrets/credentials"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "yannick"
}

variable "key_name" {
  description = "Key pair name for Jenkins EC2 access"
  type        = string
  default     = "jenkins-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "jenkins-server"
}

variable "root_volume_size" {
  description = "Root disk size in GiB"
  type        = number
  default     = 20
}

variable "ebs_size" {
  description = "Additional EBS volume size in GiB"
  type        = number
  default     = 10
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet and EBS"
  type        = string
  default     = "us-east-1a"
}
