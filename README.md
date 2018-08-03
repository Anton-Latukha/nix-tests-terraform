#### 1. Create tarballs
Have a `curl`, `git` installed.
Run `1-make-tarballs.sh`. Script creates temporary directory in `/tmp`, downloads set of official installers, and makes changes to integrates POSIX installer into them.
Then patched tarballs get copied to `./ready-installer`, and temporary directory script was working in - gets cleaned-up.
Then `./ready-installer` would have `install-nix.sh` - main point of entry to any platform, and `hack.sh` - a small hack to installer, that creates users and group to be a Nix workers.

#### 2. Mount `./ready-installer` to the testing environment
That directory `./ready-installer` - should be used as a volumet to mount or be copied to testing environment.

#### 3. Run installer
Run `install-nix.sh`, which would then run `install-new` - the POSIX installer which is under test.
