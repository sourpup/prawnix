# relatively basic sway setup
{ config, pkgs, inputs, ... }:

let
  ev4SwayConfig = ./sway.conf;


in  
{
  imports =
  [
    # none
  ];
 

  # use gdm as our display manager
  services.xserver = {
    desktopManager.gnome.enable = false;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    enable = true; # xwayland
    updateDbusEnvironment = true;
  };

  # use libinput
  services.libinput.enable = true;


  # use sway as our wm
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    # extraPackages = with pkgs; [
    # ];

    # use our sway config
    extraOptions = [
      "--config=${ev4SwayConfig}"
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP="sway:wlroots"
    '';
  };

  environment.systemPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard # lets manage the system clipboard from the cli
      wf-recorder
      waybar # menu bar
      mako # notification daemon
      eog # image viewer
      gcolor3 # color picker
      grim
      kanshi
      slurp
      tofi # menu/launcher
      blueman # bluetooth settings
      pavucontrol # sound settings
      alsa-tools # aplay, hda-verb, etc
      lshw
      wlogout # shutdown/reboot/logout window


      ## Utility Scripts

      # simple script which prompts the user to select a region to screenshot, and puts the image on the clipboard
      (pkgs.writeShellScriptBin "screenshot-script" ''
        ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy
      '')

      ## Desktop files

      ### Settings shortcuts
      (pkgs.makeDesktopItem {
        name = "network-settings";
        desktopName = "Network Settings";
        exec = "/run/current-system/sw/bin/alacritty --command /run/current-system/sw/bin/nmtui";
        keywords = ["wifi" "network" "networks" "ethernet" "settings"];
      })
      (pkgs.makeDesktopItem {
        name = "sound-settings";
        desktopName = "Sound Settings";
        exec = "/run/current-system/sw/bin/pavucontrol";
        keywords = ["sound" "audio" "settings"];
      })

      ### system state shortcuts
      (pkgs.makeDesktopItem {
        name = "shutdown-reboot-logout-lock-shortcut";
        desktopName = "Shutdown/Reboot/Logout/Lock";
        exec = "/run/current-system/sw/bin/wlogout";
        keywords = ["shutdown" "power" "reboot" "logout" "lock"];
      })

      ### Utility Shotcuts
      (pkgs.makeDesktopItem {
        name = "screenshot-clipboard";
        desktopName = "Screenshot to Clipboard";
        exec = "/run/current-system/sw/bin/screenshot-script";
        keywords = ["screenshot"];
      })
  ];

  # setup our bar
  programs.waybar.enable = true;

  environment.etc = {
    "xdg/waybar/config.jsonc".source = ./waybar-config.jsonc;
  };
  environment.etc = {
    "xdg/waybar/style.css".source = ./waybar-style.css;
  };

  # set up our menu/launcher
  environment.etc = {
    "xdg/tofi/tofi-config".source = ./tofi-config;
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    source-code-pro
    source-sans
    font-awesome
    powerline-fonts
    powerline-symbols
  ];


}
