

####################################################################################################################################
######################################## AWS PROVIDER VARIABLES ####################################################################

# AWS provider region: 
provider "aws" {
  region = "us-east-1" # Or use a variable if you prefer
}


# Networking: 
# Crate VPC / Subnets / Nat_Gateway / Routing / Internet_Gateway
######################################################################################

module "vpc" {
  source = "./modules/vpc"

  # --- General VPC Settings ---
  vpc_name              = "PostgreSQL_Playground_VPC_IaC"
  vpc_cidr_block        = "10.0.0.0/24"
  internet_gateway_name = "Internet_Gateway_PostgreSQL_Playground_IaC"

  # --- Availability Zone Settings ---
  availability_zone = "us-east-1a"


  # --- Subnet CIDR Block Settings ---
  public_subnet_1_cidr  = "10.0.0.0/28"
  private_subnet_1_cidr = "10.0.0.32/28"
  private_subnet_2_cidr = "10.0.0.48/28"

}


# Create ALL Security Groups: 
######################################################################################

module "security_groups" {
  source = "./modules/security_groups"

# For all SGs:
  vpc_id = module.vpc.vpc_id

  # --- PostgreSQL_EC2_Instance Sec_Group Settings ---
  postgresql_ec2_instance_cidr_block = "0.0.0.0/0"
  sec_group_name          = "PostgreSQL_EC2_Instance_SG"
  sec_group_description   = "Allow SSH / PMM and PostgreSQL Ports"
  vpc_cidr_block          = module.vpc.vpc_cidr_block         # Used for ICMP (Ping) from inside the VPC.
}


# Create and EC2: (PostgreSQL Database)
######################################################################################
module "postgresql_ec2_instance" {
  source = "./modules/postgresql_ec2_instance"

  # --- PostgreSQL_EC2_Instance Settings ---
  ami_id                  = "ami-0583d8c7a9c35822c"
  instance_type           = "t2.micro"
  key_name                = var.aws_key_pair
  subnet_id               = module.vpc.private_subnet_1_id
  postgresql_sec_group_id = module.security_groups.postgresql_ec2_instance_security_group_id
  #iam_instance_profile   = module.iam_roles............
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
