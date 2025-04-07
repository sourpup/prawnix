{ pkgs, ... }:

{

 # install alacritty
  environment.systemPackages = with pkgs; [
    alacritty
  ];

}
