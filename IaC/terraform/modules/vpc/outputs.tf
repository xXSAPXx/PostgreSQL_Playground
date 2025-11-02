

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.postgresql_vpc.id
}

output "vpc_name" {
  description = "The name of the VPC."
  value       = aws_vpc.postgresql_vpc.tags.Name
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.postgresql_vpc.cidr_block
}

output "public_subnet_1_id" {
  description = "A list of the public subnet IDs."
  value       = aws_subnet.public_subnet_1.id
}

output "private_subnet_1_id" {
  description = "A list of the private subnet IDs."
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "A list of the private subnet IDs."
  value       = aws_subnet.private_subnet_2.id
}
