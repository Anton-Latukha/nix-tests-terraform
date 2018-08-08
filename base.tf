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

  lifecycle {
    prevent_destroy = true
  }
}

#### Start containers

resource "docker_container" "nixInstTestDebian" {
  name  = "nixInstTestDebian"
  image = "${docker_image.debian.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestUbuntu" {
  name  = "nixInstTestUbuntu"
  image = "${docker_image.ubuntu.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestCentos" {
  name  = "nixInstTestCentos"
  image = "${docker_image.centos.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestArchlinux" {
  name  = "nixInstTestArchlinux"
  image = "${docker_image.archlinux.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestAlpine" {
  name  = "nixInstTestAlpine"
  image = "${docker_image.alpine.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestOpensuse" {
  name  = "nixInstTestOpensuse"
  image = "${docker_image.opensuse.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestSlackware" {
  name  = "nixInstTestSlackware"
  image = "${docker_image.slackware.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"
    read_only      = true
  }
}

resource "docker_container" "nixInstTestAndroid" {
  name  = "nixInstTestAndroid"
  image = "${docker_image.android.latest}"

  entrypoint = ["/usr/bin/sudo", "/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"

    read_only = true
  }
}

resource "docker_container" "nixInstTestTrisquel" {
  name  = "nixInstTestTrisquel"
  image = "${docker_image.trisquel.latest}"

  entrypoint = ["/data/install-nix.sh"]

  volumes = {
    volume_name    = "nix204x8664"
    container_path = "/data"

    read_only = true
  }
}

### QEMU/KVM libvirt

######################
### Declare the provider

provider "libvirt" {
  uri = "qemu:///system"
}

######################
### Basic virtual network for libVirt

resource "libvirt_network" "default" {
  name      = "default"
  addresses = ["192.168.122.0/24"]
}

######################
### Cloud volumes

# Ubuntu (it is a draft)
resource "libvirt_volume" "ubuntu-volume" {
  name   = "ubuntu-volume"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# FreeBSD
resource "libvirt_volume" "freebsd-volume" {
  name   = "freebsd-volume"
  pool   = "default"
  source = "./freebsd/FreeBSD-11.2-RELEASE-amd64.qcow2"
  format = "qcow2"
}

# OpenBSD
resource "libvirt_volume" "openbsd-volume" {
  name   = "openbsd-volume"
  pool   = "default"
  source = "./openbsd/install63.fs"
  format = "qcow2"
}

######################

# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit" "commoninit" {
  name = "commoninit.iso"

  # NOTE: Hey, place your own key! All right?
  ssh_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLbPtWNZwNZp0H/P+jsIqtib0IK/SZ2KOypM+EgW+UM pyro@rogue"
}

######################
### VMs

# Ubuntu
resource "libvirt_domain" "nix-ubuntu" {
  name   = "nix-ubuntu"
  memory = "512"
  vcpu   = 1

  cloudinit = "${libvirt_cloudinit.commoninit.id}"

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = "${libvirt_volume.ubuntu-volume.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "nix-freebsd" {
  name   = "nix-freebsd"
  memory = "512"
  vcpu   = 1

  #TODO:
  #cloudinit = "${libvirt_cloudinit.commoninit.id}"

  network_interface {
    network_name = "default"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = "${libvirt_volume.freebsd-volume.id}"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "nix-openbsd" {
  name   = "nix-openbsd"
  memory = "512"
  vcpu   = 1

  #TODO:
  #cloudinit = "${libvirt_cloudinit.commoninit.id}"

  network_interface {
    network_name = "default"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  disk {
    volume_id = "${libvirt_volume.openbsd-volume.id}"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

######################
### Print information

# Note: you can use `virsh domifaddr <vm_name> <interface>` to get the ip later
output "ubuntu@nix-ubuntu: " {
  value = "${libvirt_domain.nix-ubuntu.network_interface.0.addresses.0}"
}

output "freebsd@nix-freebsd: " {
  value = "${libvirt_domain.nix-freebsd.network_interface.0.addresses.0}"
}
