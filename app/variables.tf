variable "region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH pour Jenkins"
  type        = string
  default     = "jenkins-key" 
}

variable "instance_type" {
  description = "Type de l'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "ebs_size" {
  description = "Taille du volume EBS en GB"
  type        = number
  default     = 10
}
