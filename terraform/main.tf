provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_security_group" "default" {
    count = "${var.aws_security_group["sg_count"]}"

    name = "terraform_security_group_"
    description = "AWS security group for terraform"

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        Name = "Terraform AWS security group"
    }
}

resource "aws_elb" "web" {
    name = "terraform"

    // listener {
    //     instance_port       = 80
    //     instance_protocol   = "http"
    //     lb_port             = 443
    //     lb_protocol         = "https"
    // }
    listener {
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }

    availability_zones = [
        "${aws_instance.web.*.availability_zone}"
    ]

    instances = [
        "${aws_instance.web.*.id}",
    ]
}

resource "aws_instance" "web" {
    count = 1

    instance_type = "${var.aws_instance_type}"
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    availability_zone = "us-west-2a"

    key_name = "${var.aws_key_name}"
    security_groups = [ "${aws_security_group.default.*.name}" ]
    associate_public_ip_address = true

    connection {
        user = "${var.aws_instance_user}"
        type = "ssh"
        private_key = "${file("grap.pem")}"
        timeout = "2m"
        agent = false
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get -y install git",
            "curl -sSL https://get.docker.com/ | sudo bash",
            "sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            "git clone https://github.com/vuonghoainam/first_devops.git",
            "cd first_devops/compose",
            "docker-compose up -d",
        ]
    }

    tags {
        Name = "Terraform web ${count.index}"
    }
}