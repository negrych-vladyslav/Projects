#Provider=======================================================================
provider "aws" {}
#Data===========================================================================
data "aws_secretsmanager_secret_version" "secret" {
  secret_id = "prod/db"
}
#VPC============================================================================
module "ecs-vpc" {
  source                           = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  name                             = "${var.name}-vpc"
  cidr                             = "10.0.0.0/16"
  public_subnets                   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets                  = ["10.0.11.0/24", "10.0.22.0/24"]
  azs                              = ["eu-west-1a", "eu-west-1b"]
  enable_nat_gateway               = "true"
  default_vpc_enable_dns_hostnames = "true"
  default_vpc_enable_dns_support   = "true"
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
  source = "/home/vlad/Project_X_ECSE/modules/aws_security_group"
  ports  = ["80", "9000", "2049", "3306"]
  name   = "${var.name}-sg"
  vpc_id = module.ecs-vpc.vpc_id
}

#Load Balancer==================================================================
resource "aws_lb" "ecs_lb" {
  name            = "${var.name}-lb"
  security_groups = [module.ecs-sg.sg_id]
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
#Cloud Watch Log Group==========================================================
resource "aws_cloudwatch_log_group" "ecs_log_wordpress" {
  name = "ecs_log_wordpress"

  tags = {
    Name    = "${var.name}-log_wp"
    Project = "X"
  }
}
resource "aws_cloudwatch_log_group" "ecs_log_nginx" {
  name = "ecs_log_nginx"

  tags = {
    Name    = "${var.name}-log_nginx"
    Project = "X"
  }
}
#AWS EFS========================================================================
/*resource "aws_efs_file_system" "efs_volume" {
  performance_mode = "generalPurpose"

  creation_token = "wordpress-efs-volume"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

}

resource "aws_efs_mount_target" "ecs_temp_space_az0" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = module.ecs-vpc.private_subnets[0]
  security_groups = [module.ecs-sg.security_group_id]
}

resource "aws_efs_mount_target" "ecs_temp_space_az1" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = module.ecs-vpc.private_subnets[1]
  security_groups = [module.ecs-sg.security_group_id]
}*/
#Cluster========================================================================
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}_cluster"
  tags = {
    Name    = "${var.name}-cluster"
    Project = "ECS-X"
  }
}
#IAM============================================================================
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "ecs-execution-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}
#Task Definition================================================================
resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "ecs-task"
  cpu                      = 512
  memory                   = 3072
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  container_definitions = jsonencode([

    {
      "name" : "wordpress",
      "image" : "wordpress:latest",
      "secrets" : [
        {
          "name" : "WORDPRESS_DB_USER",
          "valueFrom" : "arn:aws:secretsmanager:eu-west-1:075589242607:secret:prod/db-xZYBk0:username::"
        },
        {
          "name" : "WORDPRESS_DB_PASSWORD",
          "valueFrom" : "arn:aws:secretsmanager:eu-west-1:075589242607:secret:prod/db-xZYBk0:password::"
        },
        {
          "name" : "WORDPRESS_DB_HOST",
          "valueFrom" : "arn:aws:secretsmanager:eu-west-1:075589242607:secret:prod/db-xZYBk0:host::"
      }]
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80
        }
      ],
      "environment" : [
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
  task_definition = aws_ecs_task_definition.ecs-task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  depends_on      = [aws_lb.ecs_lb, aws_alb_listener.ecs_listener, aws_lb_target_group.ecs_tg]

  network_configuration {
    subnets          = [module.ecs-vpc.private_subnets[0], module.ecs-vpc.private_subnets[1]]
    assign_public_ip = true
    security_groups  = [module.ecs-sg.sg_id]
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
