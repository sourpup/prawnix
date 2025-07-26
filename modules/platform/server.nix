# server platform specific configuration
{ pkgs, initrdssh-netdev-name, ... }:

{

  imports = [
      ./default.nix
  ];

  #TODO set the bootloader here?
  services.openssh.enable = true;

  # TODO move these to a server app suite?
  environment.systemPackages = with pkgs; [
    borgbackup
    btrfs-progs
    cryptsetup
    lshw
    msmtp # for sending emails on borg backup success/failure
    usbutils
  ];

}
