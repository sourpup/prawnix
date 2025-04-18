# general applications
{ config, pkgs, inputs, user, ... }:

{
  imports =
  [
    ./default.nix
    ./syncthing.nix
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


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # extra apps
    bambu-studio
    borgbackup
    chromium
    discord
    freecad-wayland
    kicad
    krita
    openscad
    qflipper
    signal-desktop
    spotify
    thunderbird
    tlp # power monitoring
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
