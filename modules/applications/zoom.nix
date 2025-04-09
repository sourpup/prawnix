# zoom is a special annoyance
{ pkgs-zoom, ... }:


{
  environment.systemPackages = with pkgs-zoom; [
    zoom-us
  ];

}
