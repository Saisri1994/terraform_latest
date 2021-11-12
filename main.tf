provider "aws"{
  region = "us-east-1"
  access_key = var.access
  secret_key = var.secret
}
resource "aws_instance" "myfirstinstance"{
  ami = var.ami
  instance_type = var.instance
  count = 3
  tags = {
    Name = "ubuntu"
  }
}
resource "aws_vpc" "main"{
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "first-subnet"{
  count = 4
  vpc_id = aws_vpc.main.id
  cidr_block= "${element(var.subnet_cidr, count.index)}"
  availability_zone = "${element(var.subnet_azs, count.index)}"
  map_public_ip_on_launch= true
    tags= {
        Name="p-subnet"
    }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "prod"
  }
}
resource "aws_route_table" "public"{
  vpc_id= aws_vpc.main.id
  route{
  #cidr_block="${element(var.subnet_cidr, count.index)}"
  gateway_id= aws_internet_gateway.gw.id
  }
}
#routetable association
/*
resource "aws_route_table_association" "a"{
  subnet_id= aws_subnet.first-subnet[count.index]
  route_table_id=aws_route_table.public.id
}
*/
resource "aws_lb_target_group" "prod_tg_lb"{
  name = "prodtglbdd"
  port = 80
  protocol = "HTTP"
  target_type= "instance"
  vpc_id = aws_vpc.main.id
 
  health_check{
    interval=10
    path="/"
    protocol="HTTP"
    timeout=5
    healthy_thershold=5
    unhealthy_thershold=2
}
#attaching instance to TG
resource "aws_lb_target_group_attachment" "my-tg-1"{
  count = length(aws_instance.base)
  target_group_arn="${aws_lb_target_group.my.target.arn}"
  target_id = aws_instance.base[count.index].id
  port=80
}
resource "aws_lb_target_group_attachment" "my-tg-1"{
  target_group_arn="${aws_lb_target_group.my.target.arn}"
  target_id = "${var.instance2.id}"
  port=80
}
resource "aws_lb_target_group_attachment" "my-tg-1"{
  target_group_arn="${aws_lb_target_group.my.target.arn}"
  target_id = "${element(var.instance.id}"
  port=80
}


resource "aws_default_security_group" "prodsg" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_elb" "alb" {
  name               = "applicationelb"
  internal = false
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  security_groups= aws_default_security_group.prodsg.id
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
/*
  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }
*/
}
