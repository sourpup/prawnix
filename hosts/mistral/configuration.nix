# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs-mistral-firmware, ... }:

let

  hostname = "mistral";
  # must be one of the .nix files in modules/platform
  platform = "laptop";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # base platform configuration
      (inputs.self + /modules/platform/${platform}.nix)
      # rb specific fixes
      (inputs.self + /modules/rb-fixes/default.nix)
      # disable the nvidia card
      (inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable)
      # configure zswap as swap
      (inputs.self + /modules/swap/zswap.nix)
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

  # Pin to an older version of linux-firmware
  # some firmware change between versions 20250917 and 20251011 causes nvme issues
  nixpkgs.overlays = [
    (self: super: {
      linux-firmware = pkgs-mistral-firmware.linux-firmware;
    })
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
