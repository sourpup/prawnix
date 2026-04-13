{ self, pkgs, ... }:

let
  host_sway_conf = (pkgs.writeTextFile {
    name = "host_sway_conf";
    text = ''

# mudpup specific sway configuration

#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0
#
# You can get the names of your outputs by running: swaymsg -t get_outputs


# Default resolution and scaling, wallpaper
# 1.6 instead of 1.5 to make 2560/1.6 equal a whole number
output * scale 1.6
output * bg /etc/wallpapers/horizontal/gris4.PNG fill

# Resolution for separate OLED monitor
output DP-2 resolution 2560x1440@119.999Hz
output DP-2 scale 1

# Monitor positioning
output DP-2  position 1600,0
output eDP-1 position 0,0



    '';
  });


in

{
  imports = [
    ./default.nix
    (self + /modules/wallpapers/default.nix)
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
