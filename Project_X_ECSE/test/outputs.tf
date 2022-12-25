output "load_balancer_dns_name" {
  value = aws_elb.ec2.dns_name
}
