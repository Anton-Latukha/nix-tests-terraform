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

#### Volume
## FIXME: For now it needs to be populated manually. Move x86_64 tarball files inside volume
resource "docker_volume" "nix204x8664" {
  name = "nix204x8664"
}

#### Start containers

resource "docker_container" "nixInstTestDebian" {
  name  = "nixInstTestDebian"
  image = "${docker_image.debian.latest}"

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
  }
}

resource "docker_container" "nixInstTestUbuntu" {
  name  = "nixInstTestUbuntu"
  image = "${docker_image.ubuntu.latest}"
}

resource "docker_container" "nixInstTestCentos" {
  name  = "nixInstTestCentos"
  image = "${docker_image.centos.latest}"
}

resource "docker_container" "nixInstTestArchlinux" {
  name  = "nixInstTestArchlinux"
  image = "${docker_image.archlinux.latest}"
}

resource "docker_container" "nixInstTestAlpine" {
  name  = "nixInstTestAlpine"
  image = "${docker_image.alpine.latest}"
}

resource "docker_container" "nixInstTestOpensuse" {
  name  = "nixInstTestOpensuse"
  image = "${docker_image.opensuse.latest}"
}

resource "docker_container" "nixInstTestSlackware" {
  name  = "nixInstTestSlackware"
  image = "${docker_image.slackware.latest}"
}
