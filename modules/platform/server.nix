# server platform specific configuration
{ pkgs, ... }:

{

  imports = [
      ./default.nix
  ];

  services.openssh.enable = true;
}
