# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, ... }:

let

  hostname = "emmerich";
  # must be one of the .nix files in modules/platform
  platform = "desktop";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # base platform configuration
      (inputs.self + /modules/platform/${platform}.nix)
      # use sway
      (inputs.self + /modules/sway/${hostname}.nix)
      # use our wallpapers
      (inputs.self + /modules/wallpapers/default.nix)
      # use zsh4humans
      (inputs.self + /modules/zsh/default.nix)
      # use alacritty
      (inputs.self + /modules/alacritty/${platform}.nix)
      # application suite
      (inputs.self + /modules/applications/graphical-full.nix)
      # application specific inclusions/configurations
      (inputs.self + /modules/applications/configs/firefox-work.nix)
      (inputs.self + /modules/applications/configs/zoom.nix)
      (inputs.self + /modules/applications/configs/wireguard.nix)
    ];

  networking.hostName = "${hostname}"; # Define your hostname.

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;  # Usually true for most systems
  };
}
