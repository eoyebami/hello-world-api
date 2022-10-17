#Module for vpc creation as well as sub resources
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Environment = "test"
  }
}

resource "aws_security_group" "allow_traffic_to_lb" {
  name        = "allow_traffic_to_lb"
  description = "Allow traffic to lb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_traffic_to_lb"
  }
}

resource "aws_security_group" "allow_traffic_to_service" {
  name        = "allow_traffic_to_service"
  description = "Allow traffic to service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Port for Container"
    from_port        = 8888
    to_port          = 8888
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_traffic_to_service"
  }
}

resource "aws_lb" "hello-world-alb" {
  name               = "hello-world-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_traffic_to_lb.id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  enable_deletion_protection = false


  tags = {
   Environment = "test"
  }
}

resource "aws_lb_target_group" "ip-hello-world" {
  name        = "ip-hello-world"
  port        = 8888
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.hello-world-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-hello-world.arn
  }
}