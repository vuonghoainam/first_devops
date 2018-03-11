provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_security_group" "default" {
    count = "${var.aws_security_group.sg_count}"

    name = "terraform_security_group_${lookup(var.aws_security_group, concat("sg_", count.index, "_name"))}"
    description = "AWS security group for terraform example"

    ingress {
        from_port   = "${lookup(var.aws_security_group, concat("sg_", count.index, "_from_port"))}"
        to_port     = "${lookup(var.aws_security_group, concat("sg_", count.index, "_to_port"))}"
        protocol    = "${lookup(var.aws_security_group, concat("sg_", count.index, "_protocol"))}"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "Terraform AWS security group"
    }
}

resource "aws_elb" "web" {
    name = "terraform"

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
    availability_zone = "${lookup(var.aws_availability_zones, count.index)}"

    key_name = "${var.aws_key_name}"
    security_groups = [ "${aws_security_group.default.*.name}" ]
    associate_public_ip_address = true

    connection {
        user = "${var.aws_instance_user}"
        key_file = "${var.aws_key_path}"
    }

    provisioner "file" {
        source = "compose/"
        destination = "/tmp/"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y docker epel-release python-pip git",
            "sudo systemctl start docker.service && systemctl enable docker.service",
            "sudo pip install docker-compose",
            "git clone "
            "sudo docker run -d -p 80:80 -v /tmp:/usr/share/nginx/html --name nginx_${count.index} nginx",
            "sudo sed -iE \"s/{{ hostname }}/`hostname`/g\" /tmp/index.html",
            "sudo sed -iE \"s/{{ container_name }}/nginx_${count.index}/g\" /tmp/index.html"
        ]
    }

    tags {
        Name = "Terraform web ${count.index}"
    }
}