{ inputs, pkgs, ... }:

let
  host_sway_conf = (pkgs.writeTextFile {
    name = "host_sway_conf";
    text = ''

# mistral specific sway configuration

#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs


# Default resolution and scaling, wallpaper
output * scale 1.5
output * bg /etc/wallpapers/horizontal/cat_window.png fill

# monitor specific configurations
output DP-1 resolution 7680x2160@59.9877Hz
output DP-1 scale 1.0
output DP-1 bg /etc/wallpapers/horizontal/32_10_house_island.jpg fill

# Default wallpaper

    '';
  });
in

{
  imports = [
    ./default.nix
    (inputs.self + /modules/wallpapers/default.nix)
  ];

  # install this hosts sway config
  environment.etc = {
    "xdg/sway/sway.conf".source = (
      pkgs.concatTextFile {
        name = "sway.conf";
        files = [ ./sway.conf host_sway_conf ];
      });
  };

}
