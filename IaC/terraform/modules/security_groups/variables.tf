##############################################
# ALL SEC_GROUPS VARIABLES:
##############################################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the security groups will be created."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

####################################################
# PostgreSQL Instance SEC GROUP VARIABLES: 
####################################################

variable "sec_group_name" {
  description = "Name for the PostgreSQL Instance Security Group"
  type        = string
  default     = "postgresql_instance_sg"
}

variable "sec_group_description" {
  description = "Allow Normal DB Traffic / PMM and SSH"
  type        = string
  default     = "Allow Normal DB Traffic / PMM and SSH"
}

variable "postgresql_ec2_instance_cidr_block" {
  type        = string
  description = "CIDR block used for ingress and egress inside the VPC."
  default     = "0.0.0.0/0"
}


########################################################################
# PMM Server SEC GROUP VARIABLES:
########################################################################

variable "pmm_sec_group_name" {
  description = "Name for the PMM Instance Security Group"
  type        = string
  default     = "pmm_instance_sg"
}

variable "pmm_sec_group_description" {
  description = "Allow PMM and SSH"
  type        = string
  default     = "Allow PMM and SSH"
}

variable "pmm_ec2_instance_cidr_block" {
  type        = string
  description = "CIDR block used for ingress and egress inside the VPC."
  default     = "0.0.0.0/0"
}


########################################################################
# Trafic Generator Instance SEC GROUP VARIABLES:
########################################################################