#AWS============================================================================
provider "aws" {
  version = "3.74.0"
  region  = "eu-west-1"
}
#Launch Configure===============================================================
resource "aws_launch_configuration" "ec2" {
  name                 = "ecs-configuration"
  instance_type        = "t2.micro"
  image_id             = "ami-0ea0f26a6d50850c5"
  security_groups      = [module.ecs-sg.sg_id]
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=wordpress-cluster >> /etc/ecs/ecs.config"
  key_name             = "ssh"
}
#Autoscaling Group==============================================================
resource "aws_autoscaling_group" "ec2" {
  name                      = "ecs-autoscale"
  vpc_zone_identifier       = [module.ecs-vpc.public_subnets[0], module.ecs-vpc.public_subnets[1]]
  launch_configuration      = aws_launch_configuration.ec2.name
  load_balancers            = ["${aws_elb.ec2.name}"]
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}
#Load Balancer==================================================================
resource "aws_elb" "ec2" {
  name            = "wordpress-elb"
  security_groups = [module.ecs-sg.sg_id]
  subnets         = [module.ecs-vpc.public_subnets[0], module.ecs-vpc.public_subnets[1]]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/wp-admin/install.php"
    interval            = 30
  }
}
#DATA===========================================================================
data "aws_secretsmanager_secret_version" "secret" {
  secret_id = "prod/db"
}
