# minimal dev tools headless application set
# graphical applications should go in either graphical or graphical-full
{ pkgs, inputs, user, ... }:

{
  imports =
  [
    ./minimal.nix
  ];

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    optnix # useful for local search of nixos options

    # image tools
    ghostscript
    imagemagick

    # hardware tools
    minicom
    pciutils
    usbmuxd

    # basic dev env
    cargo # rust
    docker
    gcc14
    python3
    ruff # linter for python
    rustc

    # android dev
    android-tools

    # network tools
    dig
  ];

  # enable iphone tethering for iphone users
  services.usbmuxd.enable = true;


  # enable docker daemon
  virtualisation.docker.enable = true;
  users.users.${user} = {
    extraGroups = [
      "docker"
    ];
  };


}
