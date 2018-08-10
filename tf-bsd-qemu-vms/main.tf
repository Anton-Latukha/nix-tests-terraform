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

# FreeBSD
resource "libvirt_volume" "freebsd-volume" {
  name   = "freebsd-volume"
  pool   = "default"
  source = "./freebsd/freebsd.qcow2"
  format = "qcow2"
}

# OpenBSD
resource "libvirt_volume" "openbsd-volume" {
  name   = "openbsd-volume"
  pool   = "default"
  source = "./openbsd/install63.qcow2"
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

# FreeBSD
resource "libvirt_domain" "nix-freebsd" {
  name   = "nix-freebsd"
  memory = "512"
  vcpu   = 1

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

# OpenBSD
resource "libvirt_domain" "nix-openbsd" {
  name   = "nix-openbsd"
  memory = "512"
  vcpu   = 1

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

output "freebsd@nix-freebsd: " {
  value = "${libvirt_domain.nix-freebsd.network_interface.0.addresses.0}"
}

#TODO:
#output "openbsdd@nix-openbsd: " {
#  value = "${libvirt_domain.nix-openbsd.network_interface.0.addresses.0}"
#}

