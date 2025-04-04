{ config, pkgs, inputs, ... }:

let
  # none
in
{
  imports =
  [
    # none
  ];

# install alacritty
  environment.systemPackages = with pkgs; [
      alacritty
  ];

# install alacritty config
  environment.etc = {
    "xdg/alacritty/alacritty.toml".source = ./alacritty.toml;
  };

}
