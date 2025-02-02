# relatively basic sway setup
{ config, pkgs, inputs, ... }:

let
  ev4SwayConfig = configs/sway.conf;

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
      wl-clipboard
      wf-recorder
      waybar
      mako # notification daemon
      grim
      kanshi
      slurp
      alacritty # Alacritty is our default terminal
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      wlogout
  ];

  # setup our bar
  programs.waybar.enable = true;
  environment.etc = {
    "xdg/waybar/config.jsonc".source = configs/waybar-config.jsonc;
  };

  # set up out terminal
  environment.etc = {
    "xdg/alacritty/alacritty.toml".source = configs/alacritty.toml;
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
