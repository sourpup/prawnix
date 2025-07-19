# firefox work profile shortcut
{ pkgs, ... }:

{
  imports =
  [
    # get firefox from the graphical config
    ../graphical.nix
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    # desktop shortcuts
    (pkgs.makeDesktopItem {
      name = "firefoxWork";
      desktopName = "Firefox Work";
      exec = "/run/current-system/sw/bin/firefox -P Work";
      keywords = ["firefox" "work"];
    })
  ];

}
