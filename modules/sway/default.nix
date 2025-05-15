# relatively basic sway setup
{ pkgs, ... }:

let
  ev4SwayConfig = ./sway.conf;
in
{
  imports =
    [
      ./mako.nix # for notifications
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
    # the host specific nix file writes this
    extraOptions = [
      "--config=/etc/xdg/sway/sway.conf"
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

  # add support for auto mount
  services.udisks2.enable = true;
  security.polkit.enable = true;

  # start udiskie on login
  systemd.user.services.udiskie = {
    wantedBy = [ "graphical-session.target" ];
    description = "Drive automounter";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
     Type = "simple";
     ExecStart = "${pkgs.udiskie}/bin/udiskie";
   };

  };


  environment.systemPackages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard # lets manage the system clipboard from the cli
    wf-recorder
    waybar # menu bar
    libnotify # some applications depend on this to feed mako
    eog # image viewer
    gcolor3 # color picker
    grim
    jq
    kanshi
    slurp
    tofi # menu/launcher
    blueman # bluetooth settings
    pavucontrol # sound settings
    alsa-tools # aplay, hda-verb, etc
    lshw
    udiskie
    wlogout # shutdown/reboot/logout window
    wl-mirror # used to help us with individual window sharing
    nwg-displays

    ## Utility Scripts

    # simple script which prompts the user to select a region to screenshot, and puts the image on the clipboard
    (pkgs.writeShellScriptBin "screenshot-script" ''
      ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy
    '')

    # start virtual workspace for single window sharing
    (pkgs.writeShellScriptBin "start-share" ''
      # Step 1: Create a new output
      ${pkgs.sway}/bin/swaymsg create_output

      # Step 2: Find the name of the newly created output
      NEW_OUTPUT=$(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | select(.name | startswith("HEADLESS-")) | .name' | sort | tail -n 1)

      # Check if the output was successfully created
      if [ -z "$NEW_OUTPUT" ]; then
          echo "Failed to create a new output."
          exit 1
      fi

      # Step 3: Assign a workspace to the new output
      ${pkgs.sway}/bin/swaymsg workspace screenshare output "$NEW_OUTPUT"

      # Step 4: Set the resolution for the new output
      ${pkgs.sway}/bin/swaymsg output "$NEW_OUTPUT" resolution 1920x1080

      # Step 5: Set the background color for the new output
      ${pkgs.sway}/bin/swaymsg output "$NEW_OUTPUT" bg "#C299FF" solid_color

      # Step 6: Switch to workspace "screenshare" and then back to the previous workspace
      CURRENT_WORKSPACE=$(${pkgs.sway}/bin/swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
      ${pkgs.sway}/bin/swaymsg workspace screenshare
      ${pkgs.sway}/bin/swaymsg workspace "$CURRENT_WORKSPACE"

      trap ctrl_c INT
      function ctrl_c() {
          echo "removing output $NEW_OUTPUT"
          ${pkgs.sway}/bin/swaymsg output "$NEW_OUTPUT" unplug
          ${pkgs.libnotify}/bin/notify-send "unplugged headless output"
          exit 0
      }

      echo "Starting wl-mirror"
      echo "the headless output is likely to the right of your main workspace"
      echo "When done, close all windows on the shared workspace, then ctrl-c to tear down the screen sharing output and workspace"
      ${pkgs.wl-mirror}/bin/wl-mirror "$NEW_OUTPUT"
    '')

    ## Desktop files

    ### Settings shortcuts
    (pkgs.makeDesktopItem {
      name = "network-settings";
      desktopName = "Network Settings";
      exec = "/run/current-system/sw/bin/alacritty --command /run/current-system/sw/bin/nmtui";
      keywords = [ "wifi" "network" "networks" "ethernet" "settings" ];
    })
    (pkgs.makeDesktopItem {
      name = "sound-settings";
      desktopName = "Sound Settings";
      exec = "/run/current-system/sw/bin/pavucontrol";
      keywords = [ "sound" "audio" "settings" ];
    })

    ### system state shortcuts
    (pkgs.makeDesktopItem {
      name = "shutdown-reboot-logout-lock-shortcut";
      desktopName = "Shutdown/Reboot/Logout/Lock";
      exec = "/run/current-system/sw/bin/wlogout";
      keywords = [ "shutdown" "power" "reboot" "logout" "lock" ];
    })

    ### Utility Shotcuts
    (pkgs.makeDesktopItem {
      name = "screenshot-clipboard";
      desktopName = "Screenshot to Clipboard";
      exec = "/run/current-system/sw/bin/screenshot-script";
      keywords = [ "screenshot" ];
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

    # pre 25.05
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    # post 25.05
    #    nerd-fonts.fira-code
    #    nerd-fonts.droid-sans-mono
  ];

  # setup default applications
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "image/jpeg" = "org.gnome.eog.desktop";
    "image/png" = "org.gnome.eog.desktop";
    "image/svg" = "org.gnome.eog.desktop";
  };

}
