# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # rb specific fixes
      (inputs.self + /modules/rb-fixes/default.nix)
      # base host configuration
      (inputs.self + /modules/base-configuration/default.nix)
      # use sway
      (inputs.self + /modules/sway/default.nix)
      # use our wallpapers
      (inputs.self + /modules/wallpapers/default.nix)
      # use zsh4humans
      (inputs.self + /modules/zsh/default.nix)
      # use alacritty
      (inputs.self + /modules/alacritty/default.nix)
      # general application configs
      (inputs.self + /modules/applications/default.nix)
    ];

  networking.hostName = "mistral"; # Define your hostname.

}
