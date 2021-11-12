provider "aws"{
  region = var.region
}
#create target group 
resource "aws_lb_target_group" "alb-tg"{
  name = var.alb-tg-name
  port = var.target-group-port
  protocol = var.taregt-group-protocol
  vpc_id = var.vpc-id
}
