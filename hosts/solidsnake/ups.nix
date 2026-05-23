{ self, config, sources, lib, pkgs, user, ... }:

let
  secrets = import "${sources.prawnix-secrets-solidsnake}/default.nix";

  upsNotify = pkgs.writeShellScriptBin "upsNotify" ''
      echo -e "Subject:" "$@" | ${pkgs.msmtp}/bin/msmtp --file ${config.sops.secrets."nut/email_msmtp_conf".path} ${secrets.borgbackup.notify-emailaddress}
    '' + "/bin/upsNotify";
in
{

  environment.systemPackages = with pkgs; [
    nut # network ups tools
  ];

  # configure ups
  power.ups = {
    enable = true;
    mode = "standalone";
    ups."UPS-1" = {
      description = "UGREEN 3000 dc UPS";
      driver = "usbhid-ups";
      port = "auto";
      directives = [
        "subdriver = Arduino"
        "productid = ffff"
        "vendorid = 2b89"
        "pollinterval = 5"
        "ignorelb"
        "lowbatt = 20"
      ];
    };
     # section: The upsd daemon access control; upsd.conf
    upsd = {
      listen = [
        {
          address = "127.0.0.1";
          port = 3493;
        }
        {
          address = "::1";
          port = 3493;
        }
      ];
    };
    # section: Users that can access upsd. The upsd daemon user
    # declarations. upsd.users
    users."nut-admin" = {
      upsmon = "primary";
      passwordFile = config.sops.secrets."nut/admin_password".path;
    };
    # section: The upsmon daemon configuration: upsmon.conf
    upsmon.monitor."UPS-1" = {
      system = "UPS-1@localhost";
      powerValue = 1;
      user = "nut-admin";
      # A file that contains just the password.
      passwordFile = config.sops.secrets."nut/admin_password".path;
      type = "primary";
    };

    upsmon.settings = {
      # This configuration file declares how upsmon is to handle
      # NOTIFY events.

      NOTIFYCMD = ''"${upsNotify}"'';

      # POWERDOWNFLAG and SHUTDOWNCMD is provided by NixOS default
      # values

      # values provided by ConfigExamples 3.0 book
      NOTIFYMSG = [
        [ "ONLINE" ''"UPS %s: On line power."'' ]
        [ "ONBATT" ''"UPS %s: On battery."'' ]
        [ "LOWBATT" ''"UPS %s: Battery is low."'' ]
        [ "FSD" ''"UPS %s: Forced shutdown in progress."'' ]
        [ "SHUTDOWN" ''"Auto logout and shutdown proceeding."'' ]
        [ "COMMOK" ''"UPS %s: Communications (re-)established."'' ]
        [ "COMMBAD" ''"UPS %s: Communications lost."'' ]
        [ "NOCOMM" ''"UPS %s: Not available."'' ]
        [ "NOPARENT" ''"upsmon parent dead, shutdown impossible."'' ]
      ];
      NOTIFYFLAG = [
        [ "ONLINE" "SYSLOG+WALL+EXEC" ]
        [ "ONBATT" "SYSLOG+WALL+EXEC" ]
        [ "LOWBATT" "SYSLOG+WALL+EXEC" ]
        [ "FSD" "SYSLOG+WALL+EXEC" ]
        [ "SHUTDOWN" "SYSLOG+WALL+EXEC" ]
        [ "COMMOK" "SYSLOG+WALL+EXEC" ]
        [ "COMMBAD" "SYSLOG+WALL+EXEC" ]
        [ "NOCOMM" "SYSLOG+WALL+EXEC" ]
        [ "NOPARENT" "SYSLOG+WALL+EXEC" ]
      ];
      # every NOCOMMWARNTIME seconds, upsmon will generate a UPS
      # unreachable NOTIFY event
      NOCOMMWARNTIME = 300;
    };
  };
}
