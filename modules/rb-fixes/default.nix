# fixes for the silly razerblade hardware
{ config, pkgs, inputs, ... }:
{

  # packages for sound fixes
  environment.systemPackages = with pkgs; [
      alsa-tools # required for hda-verb
      lshw # for debugging
  ];

  # run script at startup to fix the sound
  # from https://bugzilla.kernel.org/show_bug.cgi?id=207423#c94
  systemd.services.rb_sound_fix = {
     wantedBy = [ "multi-user.target" ];
      description = "Run script to fix razerblade sound";
      serviceConfig = {
        Environment = "PATH=/run/current-system/sw/bin";
        Type = "oneshot";
        ExecStart = ./RB14_2023_enable_internal_speakers_ver2.sh; 
      };
   };
}
