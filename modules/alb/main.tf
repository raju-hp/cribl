# Create ALB
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  idle_timeout       = 60

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

# Target group for Cribl Leader
resource "aws_lb_target_group" "leader" {
  name        = "${var.name}-leader-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(var.tags, { Name = "${var.name}-leader-tg" })
}

# Target group for Cribl Workers
resource "aws_lb_target_group" "worker" {
  name        = "${var.name}-worker-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(var.tags, { Name = "${var.name}-worker-tg" })
}

# ALB listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.leader.arn
  }
}


# Attach Leader EC2 to Target Group
resource "aws_lb_target_group_attachment" "leader_attachment" {
  target_group_arn = aws_lb_target_group.leader.arn
  target_id        = var.leader_instance_id
  port             = 9000
}


# Attach Worker ASG to Worker Target Group
resource "aws_autoscaling_attachment" "worker_asg_attachment" {
  autoscaling_group_name = var.worker_asg_name
  lb_target_group_arn    = aws_lb_target_group.worker.arn
}