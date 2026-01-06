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

# Default wallpaper
output * bg /etc/wallpapers/horizontal/grove_city.png fill

# Default resolution and scaling
output * scale 1.0

# External monitors
output DP-7 resolution 7680x2160@59.987Hz
output DP-7 scale 1.2
output DP-7 dpms on
output DP-7 bg /etc/wallpapers/horizontal/future_stacked_city.png fill

    '';
  });

  host_kanshi_conf = (pkgs.writeTextFile {
    name = "host_kanshi_conf";
    text = ''

    profile docked {
      output "DP-7" enable
      output "eDP-1" disable
    }

    profile undocked {
      output "eDP-1" enable
      output "DP-7" disable
    }

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

  # install this hosts kanshi config
  environment.etc = {
    "xdg/kanshi/config".source = ( host_kanshi_conf );
  };

  # start kanshi on login
  systemd.user.services.kanshi = {
    wantedBy = [ "sway-session.target" ];
    description = "Kanshi - display auto config";
    partOf = [ "sway-session.target" ];
    after = [ "sway-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi --config /etc/xdg/kanshi/config";
      Restart = "always";
    };
  };

}
