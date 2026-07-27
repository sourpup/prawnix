{ pkgs, user, ... }:

let
  keepmenu_conf = (pkgs.writeTextFile {
    name = "keepmenu_conf";
    text = ''
    [dmenu]
    dmenu_command = tofi --config /etc/xdg/tofi/tofi-config
    pinentry = pinentry-qt
    title_path = 25

    [database]
    database_1 = ~/Keepass/Keychain.kdbx

    pw_cache_period_min = 10

    hide_groups = Recycle Bin
    '';
  });

in
{
  environment.systemPackages = with pkgs; [
    keepmenu
    pinentry-qt # required for secure password entry
  ];

  environment.etc = {
    "xdg/keepmenu/config.ini".source = ( keepmenu_conf );
  };




}
