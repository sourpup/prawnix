# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, user, primary-eth, ... }:

let

  hostname = "solidnix";
  # must be one of the .nix files in modules/platform
  platform = "server";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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


  # TODO move these to a server app suite?
  # btrfs configuration
  # services.btrfs.autoScrub.enable = true;

  environment.systemPackages = with pkgs; [
    borgbackup
    btrfs-progs
    cryptsetup
    lshw
    usbutils

  ];

# remote unlock
  boot.initrd = {
    # Enable systemd in the initial ramdisk environment
    systemd = {
      enable = true;
      # Configure networking using systemd's network manager
      network = {
        networks = {
          "${primary-eth}" = {
            matchConfig = {
              Name = "${primary-eth}";  # Matches the network interface by name
            };
            networkConfig = {
              DHCP = "yes";  # Enable DHCP to automatically get an IP address
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
          ''${inputs.prawnix-secrets.initrd_authorized_key}''
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
