# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "TA-vpc"
  }
}

# vpc endpoints for ssm 
resource "aws_vpc_endpoint" "ssm" {
  for_each           = toset(["com.amazonaws.us-east-1.ssm", "com.amazonaws.us-east-1.ssmmessages", "com.amazonaws.us-east-1.ec2messages"])
  vpc_id             = aws_vpc.main.id
  vpc_endpoint_type  = "Interface" 
  service_name       = each.value
  security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_ids         = flatten([for subnet in aws_subnet.private : subnet.id])
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.nat_eip_vpc ? length(var.availability_zones) : 0
  vpc   = true
}

# Create Public Subnet for Load Balancer
resource "aws_subnet" "public" {
  count                   = var.multi_az ? length(var.availability_zones) : 1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create Private Subnet for EC2 Instances
resource "aws_subnet" "private" {
  count             = var.multi_az ? length(var.availability_zones) : 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
  count  = var.multi_az ? length(var.availability_zones) : 1
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_eip_vpc ? aws_nat_gateway.main[0].id : null
  }
  tags = {
    Name = "private-rt"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = var.nat_eip_vpc ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "TA-ng"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = var.multi_az ? length(var.availability_zones) : 1
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = var.multi_az ? length(var.availability_zones) : 1
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = var.ec2_sg_name
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name                       = var.lb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for i in range(length(aws_subnet.public)) : aws_subnet.public[i].id]
  enable_deletion_protection = false
  tags = {
    Name = var.lb_name
  }
}

resource "aws_lb_target_group" "main" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
  tags = {
    Name = var.target_group_name
  }
}

resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = [for id in aws_subnet.private[*].id : id]

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_db_instance" "main" {
  db_name                = var.db_name
  multi_az               = false
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "main-rds-instance"
  }
}

# Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = var.rds_sg_description
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.rds_sg_ingress_port
    to_port         = var.rds_sg_ingress_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.rds_sg_egress_cidr_blocks
  }
}

# Making application scalable
resource "aws_autoscaling_group" "web" {
  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"
  }
  vpc_zone_identifier       = aws_subnet.private[*].id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Web-asg"
    value               = "web-instance"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "web" {
  name          = var.launch_template_name
  image_id      = var.launch_template_image_id
  instance_type = var.launch_template_instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm-role.arn
  }

  network_interfaces {
    associate_public_ip_address = var.launch_template_public_ip
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# creating ssm role
resource "aws_iam_role" "ssm-role" {
  name = "ssm-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}
data "aws_iam_policy" "aws_managed_policies" {
  for_each = toset([
    "AmazonSSMFullAccess",
    "AmazonSSMManagedEC2InstanceDefaultPolicy"
  ])
  arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_role_policy_attachment" "attach_policies" {
  for_each = data.aws_iam_policy.aws_managed_policies
  role       = aws_iam_role.ssm-role.name
  policy_arn = each.value.arn
}

resource "aws_iam_instance_profile" "ssm-role" {
  name = "ssm-role"
  role = aws_iam_role.ssm-role.name
}
