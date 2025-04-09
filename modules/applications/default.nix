# general applications
{ pkgs, inputs, ... }:

{
  imports =
  [
    # none
  ];


# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # basic tools
    dtrx
    fzf
    git
    nautilus
    ripgrep
    wget

    # baisc dev env
    gcc14
    python3
    ruff # linter for python

    # use our neovim/nixvim config
    inputs.nvix.packages.${pkgs.system}.core


    # other apps
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
    ncdu # tui for disk usage
    openscad
    qflipper
    signal-desktop
    spotify
    thunderbird
    vorta
    wireshark-qt
    yt-dlp
    zoom-us
    xdg-desktop-portal-wlr # required for zoom screen sharing on wayland
    xdg-desktop-portal-gtk # required for zoom screen sharing on wayland

  ];

  # configure syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    # run as user
    user = "eva";
    # lets use the usual syncthing config rather than confiuring syncthing
    # with nix
    dataDir = "/home/eva";  # default location for new folders
    configDir = "/home/eva/.config/syncthing";
    # Dont delete devices and folders that are created
    # by the web interface
    overrideDevices = false;
    overrideFolders = false;

  };

# https://github.com/NixOS/nixpkgs/issues/359533
systemd.tmpfiles.rules = [
  "L+ /usr/share/xdg-desktop-portal/portals - - - - /run/current-system/sw/share/xdg-desktop-portal/portals "
  "L+ /usr/libexec/xdg-desktop-portal-gtk - - - - ${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk "
  "L+ /usr/libexec/xdg-desktop-portal-wlr - - - - ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr "
  "L+ /usr/libexec/xdg-desktop-portal - - - - ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal "
];

}
