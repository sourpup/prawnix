# zsh with z4humans baked in
{ config, pkgs, inputs, ... }:

let
  # none
in  
{
  imports =
  [
    # none
  ];


  # this file sets simply sets ZDOTDIR=/etc/zsh, which tells zsh
  # to look in /etc/zsh for all of the things it would usually find
  # in $HOME
  # the end of the standard nixos /etc/zshenv sources it for us
  environment.etc = {
    "zshenv.local".source = ./zshenv.local;
  };
  # tell zsh to keep our compdump and history in home still
  environment.etc = {
    "zsh/.zshhomefix.zsh".source = ./.zshhomefix.zsh;
  };

  # install our zsh config files
  environment.etc = {
    "zsh/.zshrc".source = ./.zshrc;
  };
  environment.etc = {
    "zsh/.zshenv".source = ./.zshenv;
  };
  environment.etc = {
    "zsh/.p10k.zsh".source = ./.p10k.zsh;
  };

  # TODO explicitly install zsh4humans cache
  # right now when launching zsh for the first time, it will
  # download z4h things to ~/.cache
  # instead, take the zsh4humans bundle and package it so we 
  # and have it installed in /etc/zsh/<blah> for us
  # so the download doesn't have to happen at first launch
  # the location it loads from is configured in ~/.zshenv


  # setup default shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      osupdate = "sudo nixos-rebuild switch";
    };
    histSize = 100000;
  };
  # set zsh as the default shell
  users.defaultUserShell = pkgs.zsh;
  # ensure the user still shows up in GDM: https://nixos.wiki/wiki/Zsh 
  environment.shells = with pkgs; [ zsh ];
}
