# general applications
{ config, pkgs, inputs, user, ... }:

{
  imports =
  [
    ./default.nix
    ./syncthing.nix
    ./qemu.nix
  ];


# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Set Firefox as the default browser
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";

  # enable docker daemon
  virtualisation.docker.enable = true;
  users.users.${user} = {
    extraGroups = [
      "docker"
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # extra apps
    bambu-studio
    borgbackup
    cargo # rust
    chromium
    devcontainer # used for zmk build
    discord
    docker
    freecad-wayland
    ghidra # reverse engineering tools
    kicad
    krita
    mpv
    openscad
    pdftk
    pdfchain
    qflipper
    rustc # rust
    sabnzbd
    signal-desktop
    spotify
    thunderbird
    tlp # power monitoring
    vlc
    vorta
    wireshark-qt
    yt-dlp


    # desktop shortcuts
    (pkgs.makeDesktopItem {
      name = "firefoxWork";
      desktopName = "Firefox Work";
      exec = "/run/current-system/sw/bin/firefox -P Work";
      keywords = ["firefox" "work"];
    })

  ];

}
