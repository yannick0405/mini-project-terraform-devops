variable "vpc_id" {}
variable "cidr_block" {}
variable "availability_zone" {}
variable "public_rt_id" {} # On reçoit ça du VPCvariable "igw_id"
variable "igw_id" {
  type = string
}