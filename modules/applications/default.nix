# general applications
{ pkgs, inputs, ... }:

{
  imports =
  [

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
    # basic tools
    dtrx
    file
    fzf
    git
    nautilus
    nmap
    pciutils
    ripgrep
    wget

    # baisc dev env
    gcc14
    python3
    ruff # linter for python

    # use our neovim/nixvim config
    inputs.nvix.packages.${pkgs.system}.core

    # android dev
    android-tools

    #filesystem management
    gparted
    exfatprogs
    ntfs3g

    # other apps
    calibre
    gimp
    handbrake
    imagemagick
    keepassxc
    libreoffice-qt
    papers # pdf viewer
    ncdu # tui for disk usage
    tor-browser
    wireguard-tools
    zenith # top/htop replacement

  ];

}
