{ pkgs, ... }:

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
# set resolution and scaling
output DP-1 resolution 7680x2160@119.970Hz
output DP-1 scale 1.0

output DP-2 resolution 3840x2160@59.997Hz
output DP-2 scale 1.5
output DP-2 transform 180


    '';
  });
in

{
  imports = [
    ./default.nix
  ];

  # install this hosts sway config
  environment.etc = {
    "xdg/sway/sway.conf".source = (
      pkgs.concatTextFile {
        name = "sway.conf";
        files = [ host_sway_conf ./sway.conf ];
      });
  };

}
