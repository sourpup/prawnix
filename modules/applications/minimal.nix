# minimal, headless application set
# graphical applications should go in either graphical or graphical-full
{ pkgs, sources, user, ... }:

let
  nvix = import sources.nvix { inherit (pkgs.stdenv.hostPlatform) system; };
in

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
    fd
    file
    fzf
    ncdu # tui for disk usage
    nix-diff
    nmap
    ripgrep
    rsync
    ssh-to-age # for sops-nix
    tcpdump
    traceroute
    tree
    unzip
    wireguard-tools
    wget
    zenith # top/htop replacement

    optnix # useful for local search of nixos options

    # image tools
    ghostscript
    imagemagick

    # hardware tools
    minicom
    pciutils
    usbmuxd

    # use our neovim/nixvim config
    nvix.packages
  ];

  environment.variables.EDITOR = "vim";

  programs.gnupg.agent = {
     enable = true;
     pinentryPackage = pkgs.pinentry-curses;
  };

  # setup some sane git options
  programs.git.enable = true;
  programs.git.config =  {
    init = {
      defaultBranch = "main";
    };
    color = {
      ui = true;
    };
    core = {
      editor = "vim";
      pager = "less";
    };
    pull = {
      rebase = true;
    };
    push = {
      autoSetupRemote = true;
    };
  };

  # enable iphone tethering for iphone users
  services.usbmuxd.enable = true;

  programs.direnv.enable = true;
}
