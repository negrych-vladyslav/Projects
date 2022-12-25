#Cluste=========================================================================
resource "aws_ecs_cluster" "ecs" {
  name = "wordpress-cluster"
}
#ECS Service====================================================================
resource "aws_ecs_service" "ecs" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.ecs.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.ecs.arn
}
#Task Definition================================================================
resource "aws_ecs_task_definition" "ecs" {
  family                = "wordpress-ecs-task"
  container_definitions = file("wordpress_task.json")
  volume {
    name      = "nfs-storage"
    host_path = "/"
  }
}
#DATA===========================================================================
