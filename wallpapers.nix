# relatively basic sway setup
{ config, pkgs, inputs, ... }:

let
 # none
in  
{
  imports =
  [
    # none
  ];
 
  # set up our wallpapers
  environment.etc = {
    "wallpapers".source = ./wallpapers;
  };

}
