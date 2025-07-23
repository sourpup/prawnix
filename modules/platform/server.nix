# server platform specific configuration
{ pkgs, initrdssh-netdev-name, ... }:

{

  imports = [
      ./default.nix
  ];

  #TODO set the bootloader here?
  services.openssh.enable = true;

}
