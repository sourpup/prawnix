{ sources, ... }:

let
  wrappers = import sources.wrappers {};
in

{
  imports = [
    (wrappers.lib.getInstallModule {
      name = "waybar";
      value = wrappers.lib.wrapperModules.waybar;
    })
  ];

  wrappers.waybar = {
    enable = true;

    # converted form json using
    # nix eval --impure --expr 'builtins.fromJSON (builtins.readFile ./waybar-config.jsonc)'
    settings = {
      battery = {
        format = "{capacity}% {icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}% ";
        format-full = "{capacity}% {icon}";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
        format-plugged = "{capacity}% ";
        states = {
          critical = 15;
          warning = 30;
        };
      };
      clock = {
        format = "{:%H:%M - %d/%m}";
        tooltip = false;
      };
      height = 0;
      layer = "top";
      margin-bottom = 4;
      margin-left = 4;
      margin-right = 4;
      margin-top = 4;
      modules-center = [ ];
      modules-left = [
        "sway/workspaces"
        "niri/workspaces"
      ];
      modules-right = [
        "pulseaudio"
        "network"
        "battery"
        "clock"
      ];
      network = {
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "";
        format-linked = "{ifname} (No IP) ";
        format-wifi = "{essid} ";
        interval = 5;
        tooltip-format = "{ipaddr}/{cidr} {ifname} via {gwaddr} ";
      };
      position = "bottom"; # Waybar position (top|bottom|left|right)
      pulseaudio = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon}";
        format-bluetooth-muted = " {icon}";
        format-icons = {
          car = "";
          default = [
            ""
            ""
            ""
          ];
          hands-free = "";
          headphone = "";
          headset = "";
          phone = "";
          portable = "";
        };
        nospacing = 1;
        on-click = "pavucontrol";
      };
      spacing = 0;
      "sway/workspaces" = {
        all-outputs = false;
        disable-scroll = false;
        tooltip = false;
      };
      tray = {
        spacing = 10;
        tooltip = false;
      };
    };

    "style.css".content = ''

      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: "iosevka nerd font";
          font-weight: 500;
          font-size: 14px;
          padding: 0;
      }

      window#waybar {
          background: #574464;
          border: 2px solid #f1c4e0;
      }

      tooltip {
          background-color: #574464;
          border: 2px solid #F18FB0;
      }

      #clock,
      #tray,
      #battery,
      #network,
      #pulseaudio {
          margin: 6px 6px 6px 0px;
          padding: 2px 8px;
      }

      #workspaces {
          background-color: #E9729D;
          margin: 6px 0px 6px 6px;
          /*border: 2px solid #434a4c;*/
      }

      #workspaces button {
          all: initial;
          min-width: 0;
          box-shadow: inset 0 -3px transparent;
          padding: 2px 4px;
          color: #140a1d;
      }

      #workspaces button.focused {
          color: #f1c4e0;
      }

      #workspaces button.urgent {
          background-color: #e78a4e;
      }

      #clock {
          background-color: #E9729D;
          /*border: 2px solid #434a4c;*/
          color: #140a1d;
      }


      #network,
      #pulseaudio {
          background-color: #bd93f9;
          /*border: 2px solid #F18FB0;*/
          color: #f1c4e0;
      }

      #battery {
          background-color: #bd93f9;
          /*border: 2px solid #F18FB0;*/
          color: #f1c4e0;
      }

      #battery.warning,
      #battery.critical,
      #battery.urgent {
          background-color: #FF4971;
          /*border: 2px solid #F18FB0;*/
          color: #f1c4e0;
      }
    '';
  };

}
