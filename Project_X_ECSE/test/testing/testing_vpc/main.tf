#Provider=======================================================================
provider "aws" {}
#Data===========================================================================
data "aws_secretsmanager_secret_version" "ecs-secret" {
  secret_id = "prod/db"
}
#VPC============================================================================
module "ecs-vpc" {
  source             = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  name               = "${var.name}-vpc"
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
#Security Group=================================================================
module "ecs-sg" {
  source = "/home/vlad/Project_X_ECS/modules/aws_security_group"
  ports  = ["80"]
  name   = "${var.name}-sg"
  vpc_id = module.ecs-vpc.vpc_id
}
#Load Balancer==================================================================
resource "aws_lb" "ecs_lb" {
  name            = "${var.name}-lb"
  security_groups = [module.ecs-sg.security_group_id]
  subnets         = [module.ecs-vpc.public_subnets[0], module.ecs-vpc.public_subnets[1]]

  tags = {
    Name    = "${var.name}-lb"
    Project = "ECS-X"
  }
}
#ALB Listener===================================================================
resource "aws_alb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}
#Target Group===================================================================
resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.ecs-vpc.vpc_id
  tags = {
    Project = "ECS-X"
    Name    = "${var.name}-tg"
  }
}
#Cluster========================================================================
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}_cluster"
  tags = {
    Name    = "${var.name}-cluster"
    Project = "ECS-X"
  }
}
#Task Definition================================================================
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.name}-task"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions = jsonencode([
    {
      "name" : "wordpress",
      "image" : "wordpress:latest",
      "cpu" : 512,
      "memory" : 3072,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
        }
      ],
      "environment" : [
        {
          "name" : "WORDPRESS_DB_USER",
          "value" : "${data.aws_secretsmanager_secret_version.secret_string}"
        },
        {
          "name" : "WORDPRESS_DB_HOST",
          "value" : "${data.aws_secretsmanager_secret_version.secret_string}"
        },
        {
          "name" : "WORDPRESS_DB_PASSWORD",
          "value" : "${data.aws_secretsmanager_secret_version.secret_string}"
        },
        {
          "name" : "WORDPRESS_DB_NAME",
          "value" : "wordpress"
        }
      ]
    }
  ])
}
#Service========================================================================
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  depends_on      = [aws_lb.ecs_lb, aws_alb_listener.ecs_listener, aws_lb_target_group.ecs_tg]

  network_configuration {
    subnets          = [module.ecs-vpc.private_subnets[0], module.ecs-vpc.private_subnets[1]]
    assign_public_ip = true
    security_groups  = [module.ecs-sg.security_group_id]
  }

  load_balancer {
    container_name   = "wordpress"
    container_port   = 80
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
  tags = {
    Project = "ECS-X"
    Name    = "${var.name}-service"
  }
}
