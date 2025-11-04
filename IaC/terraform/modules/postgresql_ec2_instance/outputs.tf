# Private IP of the PostgreSQL EC2 Instance: 
output "postgresql_ec2_instance_internal_ip" {
  value = aws_instance.postgresql_ec2_instance.private_ip
}

