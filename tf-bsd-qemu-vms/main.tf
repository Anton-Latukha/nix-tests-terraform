### QEMU/KVM libvirt

######################
### Declare the provider

provider "libvirt" {
  uri = "qemu:///system"
}

######################
### Basic virtual network for libVirt

resource "libvirt_network" "vnet_nix_qemu_test" {
  name      = "vnet_nix_qemu_test"
  addresses = ["192.168.123.0/24"]
}

######################
### Cloud volumes

# FreeBSD
resource "libvirt_volume" "nix-freebsd-volume" {
  name   = "nix-freebsd-volume.qcow2"
  pool   = "default"
  source = "./img/freebsd11.2-compressed.qcow2"
  format = "qcow2"
}

# OpenBSD
resource "libvirt_volume" "nix-openbsd-volume" {
  name   = "nix-openbsd-volume.qcow2"
  pool   = "default"
  source = "./img/openbsd6.3-compressed.qcow2"
  format = "qcow2"
}

# NetBSD
resource "libvirt_volume" "nix-netbsd-volume" {
  name   = "nix-netbsd-volume.qcow2"
  pool   = "default"
  source = "./img/netbsd8.0-compressed.qcow2"
  format = "qcow2"
}

######################

# NOTE: 2018-08-10: From couple of days of expirience - BSDs not really good at supporting Cloudinit, so working without it
# Use CloudInit to add our ssh-key to the instance
#resource "libvirt_cloudinit" "commoninit" {
#  name = "commoninit.iso"
#
#  # NOTE: Hey, place your own key! All right?
#  ssh_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLbPtWNZwNZp0H/P+jsIqtib0IK/SZ2KOypM+EgW+UM pyro@rogue"
#}

######################
### VMs

# FreeBSD
resource "libvirt_domain" "nix-freebsd" {
  name   = "nix-freebsd"
  memory = "512"
  vcpu   = 1

  network_interface {
    network_name = "vnet_nix_qemu_test"
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
    volume_id = "${libvirt_volume.nix-freebsd-volume.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# OpenBSD
resource "libvirt_domain" "nix-openbsd" {
  name   = "nix-openbsd"
  memory = "512"
  vcpu   = 1

  network_interface {
    network_name = "vnet_nix_qemu_test"
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
    volume_id = "${libvirt_volume.nix-openbsd-volume.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# NetBSD
resource "libvirt_domain" "nix-netbsd" {
  name   = "nix-netbsd"
  memory = "512"
  vcpu   = 1

  network_interface {
    network_name = "vnet_nix_qemu_test"
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
    volume_id = "${libvirt_volume.nix-netbsd-volume.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

######################
### Print information

output "nix-freebsd: " {
  value = "${libvirt_domain.nix-freebsd.network_interface.0.addresses.0}"
}

output "nix-openbsd: " {
  value = "${libvirt_domain.nix-openbsd.network_interface.0.addresses.0}"
}

output "nix-netbsd: " {
  value = "${libvirt_domain.nix-netbsd.network_interface.0.addresses.0}"
}
