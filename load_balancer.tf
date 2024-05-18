
resource "aws_security_group" "alb_sg" {
  vpc_id        = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_alb"
  }
}
# Create an ALB
resource "aws_lb" "node_alb" {
  name               = "node-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [module.network.public_subnets["public1"], module.network.public_subnets["public2"]]

  tags = {
    Name = "Nodejs Alb"
  }
}

# Create a target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "alb-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id = module.network.vpc_id

  tags = {
    Name = "Alb Target Group"
  }
}

# Attach target group to ALB
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn  = aws_lb.node_alb.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  target_group_arn  = aws_lb_target_group.alb_target_group.arn
  target_id         = aws_instance.application.id
  port              = 3000
}
