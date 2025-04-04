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
    calibre
    chromium
    discord
    freecad-wayland
    gimp
    gparted
    handbrake
    imagemagick
    keepassxc
    kicad
    krita
    libreoffice-qt
    openscad
    qflipper
    signal-desktop
    spotify
    thunderbird
    vorta
    wireshark-qt
    zoom-us
  ];

}
