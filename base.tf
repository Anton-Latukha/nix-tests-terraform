# # An AMI
# variable "ami" {
#   description = "the AMI to use"
# }

# /* A multi
#    line comment. */
# resource "aws_instance" "web" {
#   ami               = "${var.ami}"
#   count             = 2
#   source_dest_check = false

#   connection {
#     user = "root"
#   }
# }

# Configure the Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:2376"
}

#### Funcking Images

resource "docker_image" "debian" {
  name = "debian:latest"
}

resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}

resource "docker_image" "centos" {
  name = "centos:latest"
}

resource "docker_image" "archlinux" {
  name = "base/archlinux:latest"
}

resource "docker_image" "alpine" {
  name = "alpine:latest"
}

resource "docker_image" "opensuse" {
  name = "opensuse/leap"
}

resource "docker_image" "slackware" {
  name = "vbatts/slackware"
}
