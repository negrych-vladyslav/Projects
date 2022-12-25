#VPC============================================================================
module "ecs-vpc" {
  source             = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  name               = "ecs-vpc"
  cidr               = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.22.0/24"]
  azs                = ["eu-west-1a", "eu-west-1b"]
  enable_nat_gateway = "true"
  igw_tags = {
    Name = "main"
  }
  tags = {
    Project = "ECS-X"
    Name    = "${var.name}-vpc"
  }
}

/*resource "aws_vpc" "vpc_wordpress" {
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_wordpress.id
}

resource "aws_eip" "natgw_ip_zoneA" {
  vpc = true
}

resource "aws_eip" "natgw_ip_zoneB" {
  vpc = true
}

resource "aws_nat_gateway" "natgw_zoneA" {
  allocation_id = aws_eip.natgw_ip_zoneA.id
  subnet_id     = aws_subnet.public_subnet_zoneA.id
}

resource "aws_nat_gateway" "natgw_zoneB" {
  allocation_id = aws_eip.natgw_ip_zoneB.id
  subnet_id     = aws_subnet.public_subnet_zoneB.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_wordpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_zoneA" {
  vpc_id = aws_vpc.vpc_wordpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw_zoneA.id
  }
}

resource "aws_route_table" "private_zoneB" {
  vpc_id = aws_vpc.vpc_wordpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw_zoneB.id
  }
}

resource "aws_route_table_association" "public_zoneA" {
  subnet_id      = aws_subnet.public_subnet_zoneA.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zoneB" {
  subnet_id      = aws_subnet.public_subnet_zoneB.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_zoneA" {
  subnet_id      = aws_subnet.private_subnet_zoneA.id
  route_table_id = aws_route_table.private_zoneA.id
}

resource "aws_route_table_association" "private_zoneB" {
  subnet_id      = aws_subnet.private_subnet_zoneB.id
  route_table_id = aws_route_table.private_zoneB.id
}*/
#Security group=================================================================
module "ecs-sg" {
  source = "/home/vlad/Project_X_ECSE/modules/aws_security_group"
  ports  = ["80", "3306", "2049", "9000", "22", "443"]
  name   = "ecs-sg"
  vpc_id = module.ecs-vpc.vpc_id
}
/*resource "aws_security_group" "ecs" {
  name        = "http"
  vpc_id      = aws_vpc.vpc_wordpress.id
  description = "Allow http port for wordpress containers"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_egress" {
  name        = "ec2_egress"
  vpc_id      = aws_vpc.vpc_wordpress.id
  description = "Every needed rules for the ec2 instances (nfs, mysql, http/S for yum install)"
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #  cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "elb" {
  name        = "http-egress"
  vpc_id      = aws_vpc.vpc_wordpress.id
  description = "Allow http from elb to ecs instances"
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "rds" {
  name        = "mysql"
  vpc_id      = aws_vpc.vpc_wordpress.id
  description = "Allow mysql port"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "efs" {
  name        = "nfs"
  vpc_id      = aws_vpc.vpc_wordpress.id
  description = "Allow nfs port"
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}
*/
