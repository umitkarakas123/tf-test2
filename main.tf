terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "tf-sec-gr-06-05" {
    name  = "tf-project-06-05"

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

variable "tag_name" {
    default = ["First", "Second"]
}

data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "name"
        values = ["amzn2-ami-kernel*"]
    }
}

resource "aws_instance" "apache-server06-05" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = "t2.micro"
    key_name = "formast"
    count = 2
    security_groups = ["tf-project-06-05"]
    user_data = file("create_apache.sh")

    tags = {
      "Name" = "Terraform ${element(var.tag_name, count.index)} Instance" 
    }

    provisioner "local-exec" {
        command = "echo ${self.public_ip} >> public_ip.txt"
    }
        
    provisioner "local-exec"  {
        command = "echo ${self.private_ip} >> private_ip.txt"
    }
}

output "mypublicips" {
    value = aws_instance.apache-server06-05[*].public_ip
}