variable "ami_id" {
  type        = string
  description = "AMI à utiliser pour l'EC2"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Type d'instance EC2"
}

variable "subnet_id" {
  type        = string
  description = "ID du subnet"
}

variable "sg_id" {
  type        = string
  description = "ID du Security Group"
}

variable "key_name" {
  type        = string
  description = "Nom de la clé SSH"
}

variable "instance_name" {
  type        = string
  default     = "jenkins-server"
  description = "Nom de l'instance EC2"
}

variable "root_volume_size" {
  type        = number
  default     = 8
  description = "Taille du volume root en Go"
}
