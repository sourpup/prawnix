# zoom is a special annoyance
{ pkgs, ... }:


{
  environment.systemPackages = with pkgs; [
    zoom-us
  ];

}
