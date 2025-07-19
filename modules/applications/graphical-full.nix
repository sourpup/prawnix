# general applications
{ pkgs, ... }:

{
  imports =
  [
    # smaller configs
    ./minimal.nix
    ./graphical.nix

    # application specific configs
    # these might be desirable in a smaller config
    # and require more than just a one line change to include
    ./configs/qemu.nix
    ./configs/syncthing.nix
  ];


# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # extra apps
    bambu-studio
    borgbackup
    chromium
    devcontainer # used for zmk build
    discord
    freecad-wayland
    ghidra # reverse engineering tools
    kicad
    krita
    openscad
    pdftk
    pdfchain
    qflipper
    sabnzbd
    signal-desktop
    spotify
    thunderbird
    tlp # power monitoring
    vorta
    wireshark-qt
    yt-dlp
  ];

}
