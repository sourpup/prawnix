# general applications
{ config, pkgs, inputs, ... }:

let

in  
{
  imports =
  [
    # none
  ];

  environment.systemPackages = with pkgs; [
    bambu-studio
    freecad-wayland
    keepassxc
    kicad
    qflipper
    signal-desktop
    spotify
    thunderbird
  ];

}
