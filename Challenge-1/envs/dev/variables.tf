variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames"
  type        = bool
  default     = true
}

variable "igw_name" {
  description = "Name for the Internet Gateway"
  type        = string
  default     = ""
}

variable "nat_eip_vpc" {
  description = "Whether to allocate Elastic IP for NAT Gateway"
  type        = bool
  default     = true
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to use multiple availability zones"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}

variable "alb_sg_name" {
  description = "Name for the ALB security group"
  type        = string
  default     = ""
}

variable "ec2_sg_name" {
  description = "Name for the EC2 security group"
  type        = string
  default     = ""
}

variable "lb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
  default     = ""
}

variable "target_group_name" {
  description = "Name for the target group"
  type        = string
  default     = ""
}

variable "web_instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = ""
}

variable "db_subnet_group_name" {
  description = "Name for the DB subnet group"
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  default     = ""
}

variable "rds_sg_name" {
  description = "Name for the RDS security group"
  type        = string
  default     = ""
}

variable "rds_sg_description" {
  description = "Description for the RDS security group"
  type        = string
  default     = ""
}

variable "rds_sg_ingress_port" {
  description = "Port for ingress traffic to the RDS security group"
  type        = number
  default     = 3306
}

variable "rds_sg_egress_cidr_blocks" {
  description = "CIDR blocks for egress traffic from the RDS security group"
  type        = list(string)
  default     = []
}

variable "autoscaling_group_name" {
  description = "Name for the autoscaling group"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name for the launch configuration"
  type        = string
  default     = ""
}

variable "launch_template_image_id" {
  description = "ID of the AMI for the launch configuration"
  type        = string
  default     = ""
}

variable "launch_template_instance_type" {
  description = "Instance type for the launch configuration"
  type        = string
  default     = ""
}

variable "launch_template_public_ip" {
  description = "Whether to associate a public IP address with instances launched by the launch configuration"
  type        = bool
  default     = false
}