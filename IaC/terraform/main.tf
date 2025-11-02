# Create and EC2: (PostgreSQL Database)
######################################################################################
module "postgresql_ec2_instance" {
  source = "./modules/postgresql_ec2_instance"

  # --- PostgreSQL_EC2_Instance Settings ---
  ami_id                  = "ami-0583d8c7a9c35822c"
  instance_type           = "t2.micro"
  key_name                = var.aws_key_pair
  subnet_id               = var.
  postgresql_sec_group_id = var.
  iam_instance_profile    = var.
  postgresql_tag_name     = "PostgreSQL-Source-Instance"

  # EBS Volume Settings:
  volume_size = 10
  volume_type = "gp2"
}



# Print all dynamic variables passed to specified modules after terrafrom deployment: 
# Usefull for debuging purposes.
# This ensures the modules received the correct env variables. 
########################################################################################################

output "postgresql_ec2_instance_public_ip" {
  value = module.postgresql_ec2_instance.postgresql_ec2_instance_public_ip
}
