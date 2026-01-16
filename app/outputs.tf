output "jenkins_public_ip" {
  description = "L'IP publique du serveur Jenkins"
  value       = module.eip.public_ip 
}

output "jenkins_dns" {
  description = "Le nom de domaine public"
  value       = module.ec2.instance_public_dns
}

output "ebs_volume_id" {
  description = "ID du volume EBS attaché"
  value       = module.ebs.ebs_id
}