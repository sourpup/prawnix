# minimal, headless application set
# graphical applications should go in either graphical or graphical-full
{ pkgs, inputs, user, ... }:

{
  imports =
  [

  ];

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # basic tools
    dtrx
    file
    fzf
    git
    imagemagick
    minicom
    ncdu # tui for disk usage
    nmap
    pciutils
    ripgrep
    rsync
    tree
    wireguard-tools
    wget
    zenith # top/htop replacement

    # basic dev env
    cargo # rust
    docker
    gcc14
    python3
    ruff # linter for python
    rustc

    # use our neovim/nixvim config
    inputs.nvix.packages.${pkgs.system}.core

    # android dev
    android-tools
  ];

  # enable docker daemon
  virtualisation.docker.enable = true;
  users.users.${user} = {
    extraGroups = [
      "docker"
    ];
  };


}
