{ inputs, pkgs, ... }:

let
  host_sway_conf = (pkgs.writeTextFile {
    name = "host_sway_conf";
    text = ''

# emmerich specific sway configuration

#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs
#
# set resolution, scaling, and position
# used nwg-displays to calculate the display positions
output DP-1 resolution 7680x2160@119.970Hz
output DP-1 scale 2.0
output DP-1 pos 0 1440
output DP-1 dpms on

output DP-2 resolution 3840x2160@59.997Hz
output DP-2 scale 2.0
output DP-2 transform 180
output DP-2 pos 2551 0
output DP-2 dpms on

# Default wallpaper
output DP-1 bg /etc/wallpapers/horizontal/future_stacked_city.png fill
output DP-2 bg /etc/wallpapers/horizontal/sword_and_sworcery.png fill

# workspace assignments
workspace 1 output DP-1
workspace 2 output DP-1
workspace 3 output DP-2
workspace 4 output DP-1
workspace 5 output DP-1
workspace 6 output DP-2
workspace 7 output DP-1
workspace 8 output DP-1
workspace 9 output DP-2
    '';
  });
in

{
  imports = [
    ./default.nix
    (inputs.self + /modules/wallpapers/default.nix)
  ];

  #TODO write a lil function that wraps this logic for all hosts

  # install this hosts sway config
  environment.etc = {
    "xdg/sway/sway.conf".source = (
      pkgs.concatTextFile {
        name = "sway.conf";
        files = [ ./sway.conf host_sway_conf ];
      });
  };

}
