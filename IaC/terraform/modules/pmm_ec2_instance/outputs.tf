# Public IP of the PMM EC2 Instance: 
output "pmm_ec2_instance_public_ip" {
  value = aws_instance.pmm_ec2_instance.public_ip
}
