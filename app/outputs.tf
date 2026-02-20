output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = module.eip.public_ip
}

output "jenkins_dns" {
  description = "Public DNS name of Jenkins server"
  value       = module.ec2.instance_public_dns
}

output "ebs_volume_id" {
  description = "Attached EBS volume ID"
  value       = module.ebs.ebs_id
}

output "jenkins_metadata_file" {
  description = "Local path of generated Jenkins metadata file"
  value       = local_file.jenkins_ec2_txt.filename
}
