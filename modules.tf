
#configure a security group module. 
resource "security_group_test" "{
description = "Allow inbound traffic and all outbound traffic"
vpc_id = aws_vpc.vpc


ingress = {
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_block = var.vpc_cidr
}

egress = {
from_port = 8080
to_port = 8080
protocol = "tcp"
}
}

