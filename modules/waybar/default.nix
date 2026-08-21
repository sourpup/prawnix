{ ... }:
{

  programs.waybar.enable = true;

  environment.etc = {
    "xdg/waybar/config.jsonc".source = ./waybar-config.jsonc;
  };
  environment.etc = {
    "xdg/waybar/style.css".source = ./waybar-style.css;
  };

}
