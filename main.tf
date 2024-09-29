provider "aws" {
region = "eu-west-2" 
}

#Create remote backend to allow storage of state in remote location

resource "aws_vpc" "vpc" {
cidr_block = var.vpc_cidr
tags = {}
Enviroment = "demo_enviroment"
Terraform = "true"
}

resource "aws_subnet" "private_subnet" {
vpc_id = "private_subnet_1"
cidr_block = "var.private_cidr"
}

#EC2 instance

resource "aws_instance" "ec2_test" {
instance_type = "t2_micro"
vpc_security_group_ids = [ aws-security-group.security_group_test.id ]
}

resource "aws_launch_configuration" "launch_1"{
instance_type = "t2_micro"
security_groups = [aws-security-group.security_group_test.id ]
}

resource "aws-autoscaling-group" "scale_1" {
launch_configuration = "aws_launch_configuration.launch_1"
vpc_zone_identifier = "aws_vpc.vpc"
target_group_arns = [aws_alb.alb_test.arn]
desired_capacity = 1
min_size = 2
max_size = 5

}


resource "aws_alb" "alb_test" {
name = "terraform-asg-test"
load_balancer_type = "application"
subnets = data.aws_subnet.private_subnet.id
security_groups = [aws-security-group.alb.id ]
}


resource "aws_lb_listener" "listener_load_balancer" {
load_balancer_arn = aws_alb.alb_test.arn
port = "80"
protocol = "http"

default_action {
  type = "fixed-response"
}

fixed_response {
content_type = "text/plain"
message_body = "404 : page not found"
status_code = 404
}
}

resource "aws-security-group" "alb" {
name = "terraform-example-alb"

#Allow inbound http requests

ingress {
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_block = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "tcp"
cidr_block = ["0.0.0.0/0"]
}
}

resource "aws_alb_target_group"  "alb_target" {
name = "aws_alb_target_group"
port = 8080
protocol = "http"
vpc_id = aws_vpc.vpc.id

health_check {

path = "/"
protocol = "http"
matcher = "200"
interval = 15
tuneout = 3
healthy_threshold = 2
unhealthy_threshold = 2
}
}

#attach target group to ec2 instance !
resource "aws_lb_target_group_attachment" "attach_lb" {
target_group_arn = aws_alb_target_group.alb_target.arn
target_id = aws_instance.ec2_test.id
port = 80
}

#listens for traffic and directs to alb 
resource "aws_lb_listener_rule" "listener_targetg" {
listener_arn = "aws_lb_listener.http.arn"
priority = 100

condition {
path_pattern {
values = [ "*" ]
}
}
action {
type = "forward"
target_group_arn = "aws_alb_target_group.alb_target.arn"
}
}



