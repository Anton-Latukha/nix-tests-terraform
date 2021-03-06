This repo is supportive testing suite to the POSIX-compatile Nix installer, what resides [here](https://github.com/NixOS/nix/pull/1565).

#### 1. Create tarballs
Have a `curl`, `git` installed.

Run `1-make-tarballs.sh`. Script would:

1a. Creates temporary directory in `/tmp`

1b. Gathers info from official one-liner

1c. Downloads set of official installers

1d. Intetgrates new POSIX installer to all OS&Arch-dependent bundles

1e. Gathers all OS&Arch-dependent bundles in `./ready-installer`

1f. Makes a hook to run according to platform OS&Arch-dependent bundle

1g. Script makes a clean-up of any additional products of script. Script deletes temporary directory aka `/tmp/nix-binary-tarball-unpack.XXXXXXXXXX`, in which it worked in.

So,
Patched tarballs get copied to `./ready-installer`, and temporary directory script was working in - gets cleaned-up.
Then `./ready-installer` has `install-nix.sh` - main point of entry to any platform, and `hack.sh` - a small hack to installer, that creates users and group to be a Nix workers.

#### 2. Mount `./ready-installer` to the testing environment
That directory `./ready-installer` - should be used as a volume to mount or be copied to testing environment.

#### 3. Run installer
Run `install-nix.sh`, which would then run `install-new` - the POSIX installer which is under test.

#### To use the full automated pipeline
1. Install `terraform`, `terraform-provider-libvirt`, `cdrtools`.
2. In a repo directory run `terraform init -plugin-dir /run/current-system/sw/bin/`.
3. Run `terraform plan` observe changes.
4. Run `terraform apply`.
5. If `libVirt` complains that virtual network is not active - enable `virt-manager > edit > connection details > virtual networks > {network name} > Autostart: + On boot`. Or in your KVM UI/CLI tool of choise. Or change the virtual network name to one you are using.
6. To found KVM IPs - `terraform show`.

#### Multi-OS Testing using Terraform
Install Docker.

```shell
cd tf-linux-containers
terraform init
terraform apply
# Confirm typing: yes
```

Terraform would run all the containers described in `main.tf`.
```shell
# See the state of containers:
docker ps -a
# See test run results with:
docker logs <container name or ID>
# If the installation gone successfully - installer reports it.
```
