# Create and EC2: (PostgreSQL Database)
######################################################################################
module "postgresql_ec2_instance" {
  source = "./modules/postgresql_ec2_instance"

  # --- PostgreSQL_EC2_Instance Settings ---
  ami_id                = "ami-0583d8c7a9c35822c"
  instance_type         = "t2.micro"
  key_name              = var.aws_key_pair

  # EBS Volume Settings:
  volume_size = 10
  volume_type = "gp2"
}
