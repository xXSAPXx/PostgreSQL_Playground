###################################################################################
# Generate a new base64 encoded userdata script for the PMM EC2.
# With Added Dynamic Variables if needed.
# This script must be passed to the PMM EC2 instance.
###################################################################################

locals {
  pmm_ec2_instance_userdata = templatefile("${path.module}/pmm_ec2_instance_user_data.tpl", {
    postgresql_internal_ip = var.postgresql_internal_ip
  })
}


########################################################################
# Public EC2 - PMM + Bastion Host + DB Traffic Generator Server:
########################################################################

resource "aws_instance" "pmm_ec2_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.pmm_sec_group_id]
  key_name               = var.key_name
  user_data              = base64encode(local.pmm_ec2_instance_userdata)

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = var.pmm_tag_name
  }
}

