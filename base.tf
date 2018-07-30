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
  name = "debian"
}

# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }


# resource "docker_image" "ubuntu" {
#   name = "ubuntu:latest"
# }

