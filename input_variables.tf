
variable "vpc_cidr" {
type = string 
default = "10.0.0.0/16"
}

variable "private_cidr" {
type = string 
default = "10.0.0.5"
}

variable "cluster-name" {
description = "the name of the cluster"
type = string
}

variable "db-remote-state-bucket" {
description = "the name of s3 bucket for db remote state"
type = string
}

variable "db-remote-state-key"{
description = "path of database remote state in s3"
type = string
}

variable "instance_type" {
description = "type of instance"
type = string 
}

