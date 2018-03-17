variable "aws_region" {
  default = "us-west-2"
}
variable "aws_key_name" {
    default = "grap"
}
variable "aws_key_path" {
    default = "./aws_credentials"
}
variable "aws_instance_type" {
    default = "t2.nano"
}
variable "aws_instance_user" {
    default = "ubuntu"
}
variable "aws_amis" {
    default = {
        us-west-2 = "ami-e1906781"
    }
}
variable "aws_availability_zones" {
    default = {
        "0" = "us-west-2a",
        "1" = "us-west-2b",
        "3" = "us-west-2c"
    }
}

variable "github_credentials" {
    default = {
        "userpass":"xxxx:xx",
        "secret_key": "sha256:..."   
    }
}

variable "aws_security_group" {
    default = {
        sg_count                = 1

        sg_0_name               = "http"
        sg_0_ingress_from_port  = 80
        sg_0_ingress_to_port    = 80
        sg_0_protocol           = "http"
    }
}
