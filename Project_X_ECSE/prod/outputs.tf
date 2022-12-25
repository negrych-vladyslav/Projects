output "load_balancer_dns_name" {
  value = aws_lb.ecs_lb.dns_name
}
