terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}
# Configure the Docker provider
#provider "docker" {
#  host = "tcp://127.0.0.1:2376"
#}

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
  name = "archlinux:latest"
}

resource "docker_image" "alpine" {
  name = "alpine:latest"
}

resource "docker_image" "opensuse" {
  name = "opensuse/leap:latest"
}

resource "docker_image" "slackware" {
  name = "vbatts/slackware:latest"
}

resource "docker_image" "android" {
  name = "circleci/android:api-28-alpha"
}

resource "docker_image" "trisquel" {
  name = "kpengboy/trisquel:latest"
}

#### Volume
## FIXME: For now it needs to be populated manually. Move x86_64 tarball files inside volume
resource "docker_volume" "nix204x8664" {
  name = "nix204x8664"
}

#### Start containers

resource "docker_container" "nixInstTestDebian" {
  name  = "nixInstTestDebian"
  image = docker_image.debian.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestUbuntu" {
  name  = "nixInstTestUbuntu"
  image = docker_image.ubuntu.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestCentos" {
  name  = "nixInstTestCentos"
  image = docker_image.centos.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestArchlinux" {
  name  = "nixInstTestArchlinux"
  image = docker_image.archlinux.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestAlpine" {
  name  = "nixInstTestAlpine"
  image = docker_image.alpine.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestOpensuse" {
  name  = "nixInstTestOpensuse"
  image = docker_image.opensuse.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestSlackware" {
  name  = "nixInstTestSlackware"
  image = docker_image.slackware.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestAndroid" {
  name  = "nixInstTestAndroid"
  image = docker_image.android.latest

  entrypoint = ["/usr/bin/sudo", "/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"

    read_only = true
  }
}

resource "docker_container" "nixInstTestTrisquel" {
  name  = "nixInstTestTrisquel"
  image = docker_image.trisquel.latest

  entrypoint = ["/data/install-nix.sh"]

  volumes {
    volume_name    = "nix204x8664"
    container_path = "/data"

    read_only = true
  }
}
