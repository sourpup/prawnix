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
    imagemagick
    minicom
    ncdu # tui for disk usage
    nmap
    optnix # useful for local search of nixos options
    pciutils
    ripgrep
    rsync
    traceroute
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

  environment.variables.EDITOR = "vim";

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


  # enable docker daemon
  virtualisation.docker.enable = true;
  users.users.${user} = {
    extraGroups = [
      "docker"
    ];
  };


}
