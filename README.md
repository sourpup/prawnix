a multi-host flake which defines a reasonable nixos system, made up of:
- sway
- gdm
- a number of tools for settings management (wifi, bluetooth, sound, etc)
- alacritty
- zsh
- neovim (nixvim via a nvix fork)

this flake is configured for my use case, but you might find the modules helpful.
laptop, desktop, and server uses are considered

## Usage Instructions:
1) If you have a fresh nixos install be sure to do the following in `/etc/nixos/configuration.nix`:
  - enable flakes
  - add git
  - set your machines hostname
2) Create a <hostname>.nix file in the hosts directory. use one of the existing hosts as an example. emmerich is a desktop, mistral is a laptop
  - be sure to copy your machines `/etc/nixos/hardware-configuration.nix` to your new hosts directory
3) add a `nixosConfigurations.<hostname>` section to the `flake.nix` file
4) `sudo nixos-rebuild --flake "path-to-flake" switch` should then just work


## CM3588 install (ignore this if you are not using a CM3588 board)

- boot from sd card (TODO, flesh out these instructions)
- partition the emmc
```
sudo wipefs -a /dev/mmcblk0
sudo parted /dev/mmcblk0 -- mklabel gpt
sudo parted /dev/mmcblk0 -- mkpart idbloader 64s 16383s # say Ignore to alightment optimization
sudo parted /dev/mmcblk0 -- mkpart uboot 16384s 32767s
sudo parted /dev/mmcblk0 -- mkpart boot 32768s 16809983s
sudo parted /dev/mmcblk0 -- mkpart primary 16809984s 100%
sudo parted /dev/mmcblk0 -- set 3 boot on
```

- setup luks
https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems
```
sudo cryptsetup luksFormat /dev/mmcblk0p4
sudo cryptsetup luksOpen /dev/mmcblk0p4 crypted
sudo mkfs.ext4 /dev/mapper/crypted
sudo mount /dev/mapper/crypted /mnt
sudo mkdir /mnt/boot
sudo mount /dev/mmcblk0p3 /mnt/boot
```

- setup boot partition
```
sudo mkfs.fat /dev/mmcblk0p3
sudo mount /dev/mmcblk0p3 /mnt/boot

```

- copy over the bootloaders
```
sudo dd if=/dev/mmcblk1p1 of=/dev/mccblk0p1 bs=512 && sync
sudo dd if=/dev/mmcblk1p2 of=/dev/mccblk0p2 bs=512 && sync
```



- generate the config
```
sudo nixos-generate-config --root /mnt
```

- ensure openssh and user are set in configuration.nix
```
/mnt/etc/nixos/configuration.nix
```

- install
```
sudo nixos-install
```

- ensure we can ssh in
```
sudo cp -a /home/nixos/.ssh /mnt/home/eva/.ssh
```

TODO: ensure ssh auth keys are set on new install

TODO:
had to explicitly set the latest kernel to get 6.12 with support with this board
```
boot.kernelPackages = pkgs.linuxPackages_latest;

```

had to explicitly set the dtb to use
```
hardware.deviceTree.name = "rockchip/rk3588-friendlyelec-cm3588-nas.dtb";


```


after reboot, had to set the time, otherwise nixos-rebuild would fail
```
date -s "22 JUL 2025 18:00:00"
```

had to enable our ethernet module in initrd
```
boot.initrd.availableKernelModules = ["r8169"];
```


### setup luks and format data disks
`sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/prawnix/hosts/solidsnake/data-disks.nix`

### backup luks headers for rootfs and data disks
`sudo cryptsetup luksHeaderBackup /dev/mmcblk0p4 --header-backup-file luks_header.bin`
