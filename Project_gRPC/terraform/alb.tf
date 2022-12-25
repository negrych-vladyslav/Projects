resource "aws_alb_target_group" "this" {
  name        = "this-tg"
  protocol           = "HTTP"
  protocol_version   = "GRPC"
  port        = 80
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    port              = 3001
    interval          = 30
    healthy_threshold = 5 
    matcher = 12
  }

  tags    = var.common_tags
}

resource "aws_alb_listener_rule" "this" {
  listener_arn = var.shared_alb_listener

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
