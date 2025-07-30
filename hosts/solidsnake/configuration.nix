# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, lib, pkgs, user, primary-eth, ... }:

let

  hostname = "solidnix";
  # must be one of the .nix files in modules/platform
  platform = "server";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # /mnt/data configuration
      ./data-disks.nix
      # platform specific configuration
      (inputs.self + /modules/platform/${platform}.nix)
      # use zsh4humans
      (inputs.self + /modules/zsh/default.nix)
      # application suite
      (inputs.self + /modules/applications/minimal.nix)
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # need to explicitly tell extlinuix to use the correct dtb
  hardware.deviceTree.name = "rockchip/rk3588-friendlyelec-cm3588-nas.dtb";

  networking.hostName = "${hostname}"; # Define your hostname.

  # install disko-mount
  # use this to mount the data disks created by data-disks.nix
  environment.systemPackages = [
    config.system.build.mount # disko-mount
  ];

  # user for docker to run as for files
  # it needs r/w access to, like configs
  users ={
    groups = {
        dockerdata = {
            gid = 1002;
          };
    };
    users.dockerdata = {
      isSystemUser = true;
      group = "dockerdata";
      uid = 1002;
      description = "${user}";
    };
  };

  # add main user to dockerdata group
  users.users.${user} = {
    extraGroups = [ "dockerdata" ];
  };



  networking.firewall.allowedTCPPorts = [
    # open web ports for ssl reverse proxy host mode docker
    80
    443

    # open web ports for syncthing host mode docker
    # https://github.com/syncthing/syncthing/blob/main/README-Docker.md#discovery
    8384
    22000
  ];

  networking.firewall.allowedUDPPorts = [
    # open web ports for syncthing host mode docker
    # https://github.com/syncthing/syncthing/blob/main/README-Docker.md#discovery
    22000
    21027
  ];

  # btrfs configuration
  # services.btrfs.autoScrub.enable = true;

# local borg backup filesystem mount
 fileSystems."/mnt/local_backup" = {
   device = "/dev/disk/by-id/usb-WD_Elements_25A3_56594A53424A504D-0:0-part1";
   fsType = "ext4";
 };

# borg backup services and timers
  systemd.services.local-borg-backup = {
     wantedBy = [ "multi-user.target" ];
     after = [ "data.mount" "mnt-local_backup.mount" ];
      description = "Run borg to backup /data/* to /mnt/local_backup/borg-backups";
      serviceConfig = {
        Environment = "PATH=/run/current-system/sw/bin";
        ExecStart = "${./create_local_backups.sh} ${inputs.prawnix-secrets.borgbackup-notify-emailaddress}";
      };
   };

  # run local backups nightly ~10 minutes after midnight
  systemd.timers.local-borg-backup = {
    description = "Timer to run local-borg-backup.service nightly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
        Unit = "local-borg-backup.service";
        OnCalendar = "*-*-* 00:10:00";
        Persistent = true;
        RandomizedDelaySec = 300;
      };
  };

  systemd.services.remote-borg-backup = {
     wantedBy = [ "multi-user.target" ];
     after = [ "data.mount" ];
      description = "Run borg to backup to remote borg repo";
      serviceConfig = {
        Environment = "PATH=/run/current-system/sw/bin";
        ExecStart = "${./create_remote_backups.sh} ${inputs.prawnix-secrets.borgbackup-notify-emailaddress}";
      };
   };

  # run remote backups nightly ~20 minutes after 1am
  systemd.timers.remote-borg-backup = {
    description = "Timer to run remote-borg-backup.service nightly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
        Unit = "local-borg-backup.service";
        OnCalendar = "*-*-* 01:20:00";
        Persistent = true;
        RandomizedDelaySec = 300;
      };
  };


# remote unlock
  boot.initrd = {
    # Enable systemd in the initial ramdisk environment
    systemd = {
      enable = true;
      # Configure networking using systemd's network manager

      # if you don't need to override any of the
      # normal running systems network interface configuration
      # you can remove this section
      network = {
        enable = true;
        # mkForce is required to override the normal systems
        # MAC and hostname
        networks =  lib.mkForce {
          "${primary-eth}" =  {
            matchConfig = {
              Name = "${primary-eth}";  # Matches the network interface by name
            };
            networkConfig = {
              DHCP = "yes";  # Enable DHCP
            };
            # set a different mac address for the initrd so the router
            # can assign a different static ip for the initrd
            # this ensures that any open ports on the router, which
            # route to the server during normal operation, are not
            # routed to the servers initrd
            linkConfig = {
              MACAddress =  "d2:c5:07:41:ad:80";
            };
            # set a different hostname for the initrd to differentiate
            # it from the normal-running system
            dhcpV4Config = {
              Hostname =  "${hostname}-decrypt";
            };
            dhcpV6Config = {
              Hostname = "${hostname}-decrypt";
            };
          };
        };
      };
    };

    # Configure SSH access during early boot
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;  # Use a non-standard port for security
        # Only allow running the unlock service when connecting via SSH
        authorizedKeys = [
          ''command="systemctl default" ${inputs.prawnix-secrets.initrd_authorized_key}''
          ''command="systemctl default" ${inputs.prawnix-secrets.initrd_authorized_key2}''
        ];
        # Location of the SSH host key
        # TODO document creating a key here as part of setup
        # sudo ssh-keygen -t ed25519 -f /etc/ssh/initrd_ssh_host_ed25519_key -C "eva@host"
        hostKeys = [ inputs.prawnix-secrets.initrd_ssh_host_key ];
      };
    };
  };

  # TODO migrate server scripts

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
