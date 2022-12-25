provider "aws" {}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = "prod/db"
}
locals {
  rds_username = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["username"]
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["password"]
}
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "test1-task"
  cpu                      = 512
  memory                   = 3072
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
          "value" : "${local.rds_username}"
        },
        {
          "name" : "WORDPRESS_DB_HOST",
          "value" : "mysqldb.cbvhjwlvuevz.eu-west-1.rds.amazonaws.com"
        },
        {
          "name" : "WORDPRESS_DB_PASSWORD",
          "value" : "${local.rds_password}"
        },
        {
          "name" : "WORDPRESS_DB_NAME",
          "value" : "wordpress"
        }
      ]
    }
  ])
}
