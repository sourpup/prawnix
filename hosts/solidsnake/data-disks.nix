# creates 4x luks containers on 4x nvme drives
# then creates a single btrfs RAID 10 volume across them
# this is not intended to be used as a root/boot device, rather as encrypted data storage
# each device has its own luks key
# instead use `disko-mount` to mount them
# disko-mount can be added to your system by adding the following to your configuration.nix
#   environment.systemPackages = [ config.system.build.mount ];


# use sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount prawnix/hosts/solidsnake/data-disks.nix
# to create

{
  disko.rootMountPoint = ""; # work around bug where this gets set to /mnt by default. Some fields are then set to `disko.rootMountPoint/device.<...>.mountpoint` while others (like the /etc/fstab entry) just use `device.<...>.mountpoint`.

  disko.devices = {
    disk = {
      # Devices will be mounted and formatted in alphabetical order, and btrfs can only mount raids
      # when all devices are present. So we define an "empty" luks device on the first 3 disks,
      # and the actual btrfs raid on the last disk, and the name of these entries matters!
      disk0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
            type = "luks";
            name = "disk0"; # device-mapper name when decrypted
            initrdUnlock = false; # dont try to unlock this in the initrd
            settings = {
              allowDiscards = true;
          };
        };
      };
      disk1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
            type = "luks";
            name = "disk1"; # device-mapper name when decrypted
            initrdUnlock = false; # dont try to unlock this in the initrd
            settings = {
              allowDiscards = true;
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
            type = "luks";
            name = "disk2"; # device-mapper name when decrypted
            initrdUnlock = false; # dont try to unlock this in the initrd
            settings = {
              allowDiscards = true;
          };
        };
      };
      disk3 = {
        type = "disk";
        device = "/dev/nvme3n1";
        content = {
          type = "luks";
          name = "disk3"; # device-mapper name when decrypted
          initrdUnlock = false; # dont try to unlock this in the initrd
          settings = {
            allowDiscards = true;
          };
          content = {
            type = "btrfs";
            extraArgs = [
              "-d raid10"
              "/dev/mapper/disk0" # Use decrypted mapped device, same name as defined in disk0
              "/dev/mapper/disk1" # Use decrypted mapped device, same name as defined in disk1
              "/dev/mapper/disk2" # Use decrypted mapped device, same name as defined in disk2
              # disk3 is passed in by by default
            ];
            subvolumes = {
              "data" = {

                mountpoint = "/data";
                mountOptions = [
                  "defaults" # use the sane btrfs mount defaults
                  "noauto" # ensure that systemd doesnt try to mount this at boot
                  "nofail" # ensure that systemd failing to mount this doesn't send us to emergency mode
                  "noatime"
                  "ssd"
                ];
              };
            };
          };
        };
      };
    };
  };
}
