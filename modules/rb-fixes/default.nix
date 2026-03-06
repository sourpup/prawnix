# fixes for the silly razerblade hardware
{ pkgs, ... }:

let

rb-fix-script = ((pkgs.writeShellApplication {
  name = "rb-fix-script";

  runtimeInputs = with pkgs; [
      alsa-tools # required for hda-verb
  ];

  text = builtins.readFile ./RB14_2023_enable_internal_speakers_ver2.sh;

}) + "/bin/rb-fix-script");

in

{

  environment.systemPackages = with pkgs; [
      alsa-utils # aplay
      lshw # for debugging
  ];

  # run script at startup to fix the sound
  # from https://bugzilla.kernel.org/show_bug.cgi?id=207423#c94
  systemd.services.rb_sound_fix = {
     wantedBy = [ "multi-user.target" ];
      description = "Run script to fix razerblade sound";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = rb-fix-script;
      };
   };
}
