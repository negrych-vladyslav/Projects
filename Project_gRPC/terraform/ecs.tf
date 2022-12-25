resource "aws_ecs_task_definition" "load_balacer_task_def" {
  family       = "${var.service_name}-proxy-${lower(var.environment_name)}"
  network_mode = "awsvpc"
  requires_compatibilities = [
  "FARGATE"]
  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = "<task-iam-role>"
  execution_role_arn = "<task-iam-role>"

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.envoy_docker_container_url}",
    "name": "${var.envoy_container_name}",
    "esssential": true,
    "portMappings": [
      {
        "containerPort": 90,
        "protocol": "tcp",
        "hostPort": 90
      },
      {
        "containerPort": 8081,
        "protocol": "tcp",
        "hostPort": 8081
      }
    ],
    "environment": [
      { "name" : "LISTEN_PORT", "value" : "90" },
 # this is the ecs service discovery endpoint for our service      { "name" : "SERVICE_DISCOVERY_ADDRESS", "value" : "sample-grpc.api.com" },
      { "name" : "SERVICE_DISCOVERY_PORT", "value" : "50051" }
      ]
  }
]
DEFINITION
}
