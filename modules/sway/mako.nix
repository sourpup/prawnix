# run mako (notification client) with our config options
{ pkgs,... }:

let

  # Wrap mako to run with our config options
  mako-wrapped = pkgs.symlinkJoin {
    name = "mako-wrapped";
    paths = [pkgs.mako];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/mako --add-flags "\
      --border-size 2 \
      --background-color '#574464' \
      --border-color '#f1c4e0' \
      --text-color '#f1c4e0' \
      --progress-color '#f1c4e0' \
      --default-timeout 2000 \
      --max-visible 3 \
      "
      '';
    };

in
{

  # Run our wrapped mako as a systemd user service
  systemd.user.services.mako-wrapped = {
    wantedBy = [ "graphical-session.target" ];
    description = "Lightweight Wayland notification daemon";
    documentation = [ "man:mako(1)" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    bindsTo= [ "dbus.service" ];

    serviceConfig = {
     Type = "dbus";
     BusName = "org.freedesktop.Notifications";
     ExecCondition = "/bin/sh -c '[ -n $WAYLAND_DISPLAY ]'";
     ExecStart = "${mako-wrapped}/bin/mako";
     ExecReload = "${mako-wrapped}/bin/mako reload";
   };

  };

}
