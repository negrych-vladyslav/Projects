output "load_balancer_dns_name" {
  value = aws_lb.ecs_lb.dns_name
}
output "sg_id" {
  value = module.ecs-sg.sg_id
}
output "private_subnet_1" {
  value = module.ecs-vpc.private_subnets[0]
}
output "private_subnet_2" {
  value = module.ecs-vpc.private_subnets[1]
}
