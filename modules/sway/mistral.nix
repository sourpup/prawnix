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


# resolution and scaling
output * scale 1.5

# Default wallpaper
output * bg /etc/wallpapers/horizontal/cat_window.png fill

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
