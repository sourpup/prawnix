{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.fuzzel ];

  # set up our menu/launcher
  environment.etc = {
    "xdg/fuzzel/fuzzel.ini".source = ./fuzzel.ini;
  };

}
