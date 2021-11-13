module "test-ec2-sg" {
  source = "./modules/ec2-sg"
  region = "eu-west-2"
  vpc-id = "${module.vpc.vpc-id}"
  ec2-sg-name = "ec2-sg"
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
