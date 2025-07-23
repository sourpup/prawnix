# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, ... }:

let

  hostname = "solidsnake";
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

  networking.hostName = "${hostname}"; # Define your hostname.


  # TODO move these to a server app suite?
  # btrfs
  services.btrfs.autoScrub.enable = true;


  environment.systemPackages = with pkgs; [
    borgbackup
    btrfs-progs
    cryptsetup
    lshw
    usbutils

  ];

  # TODO do the initial install next and get our hardware config and bootloader config
  # TODO migrate server scripts

  #TODO set the bootloader here?

}
