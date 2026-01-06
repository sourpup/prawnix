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
    fd
    file
    fzf
    ncdu # tui for disk usage
    nmap
    ripgrep
    rsync
    tcpdump
    traceroute
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
    inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.core
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

}
