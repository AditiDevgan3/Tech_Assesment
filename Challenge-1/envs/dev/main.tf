terraform {
  required_version = ">= 0.13.1"
}

module "vpc" {
  source = "../../network-module"

  vpc_cidr_block                = var.vpc_cidr_block
  enable_dns_support            = var.enable_dns_support
  enable_dns_hostnames          = var.enable_dns_hostnames
  igw_name                      = var.igw_name
  nat_eip_vpc                   = var.nat_eip_vpc
  public_subnet_cidr_blocks     = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks    = var.private_subnet_cidr_blocks
  multi_az                      = var.multi_az
  availability_zones            = var.availability_zones
  alb_sg_name                   = var.alb_sg_name
  ec2_sg_name                   = var.ec2_sg_name
  lb_name                       = var.lb_name
  target_group_name             = var.target_group_name
  web_instance_type             = var.web_instance_type
  db_subnet_group_name          = var.db_subnet_group_name
  db_instance_class             = var.db_instance_class
  db_name                       = var.db_name
  db_username                   = var.db_username
  db_password                   = var.db_password
  rds_sg_name                   = var.rds_sg_name
  rds_sg_description            = var.rds_sg_description
  rds_sg_ingress_port           = var.rds_sg_ingress_port
  rds_sg_egress_cidr_blocks     = var.rds_sg_egress_cidr_blocks
  autoscaling_group_name        = var.autoscaling_group_name
  launch_template_name          = var.launch_template_name
  launch_template_image_id      = var.launch_template_image_id
  launch_template_instance_type = var.launch_template_instance_type
  launch_template_public_ip     = var.launch_template_public_ip
}