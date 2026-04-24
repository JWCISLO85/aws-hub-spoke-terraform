
#==============================================================================
# OUTPUTS
# Display important values after terraform apply
#==============================================================================


#Bastion Host Outputs
output "bastion_public_ip" {
  value       = aws_eip.bastion_eip.public_ip
  description = "Public IP address of the bastion host"

}

output "bastion_ssh_command" {
  value       = "ssh -i ~/.ssh/jonnys-hub-key-new ec2-user@${aws_eip.bastion_eip.public_ip}"
  description = "Command to SSH into bastion"
}

output "bastion_instance_id" {
  description = "Instance ID for bastion host(Needed for Session Manager)"
  value       = aws_instance.bastion.id

}

output "novastream_instance_id" {
  description = "Instance ID for NovaStream server (Needed for Session Manager)"
  value       = aws_instance.healthcare_server.id

}

output "healthcare_instance_id" {
  description ="Instance ID for Healthcare server (Needed for Session Manager)"
  value       = aws_instance.healthcare_server.id
}