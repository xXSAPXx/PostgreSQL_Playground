########################################################################
# Security Group for the PostgreSQL Instance: 
########################################################################

resource "aws_security_group" "postgresql_ec2_instance_sg" {
  name        = var.sec_group_name
  description = var.sec_group_description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.postgresql_ec2_instance_cidr_block]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.postgresql_ec2_instance_cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.postgresql_ec2_instance_cidr_block, var.vpc_cidr_block] # Ping from outside and inside the VPC.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


########################################################################
# Security Group for the PMM Server: 
########################################################################



########################################################################
# Security Group for the Trafic Generator Instance: 
########################################################################