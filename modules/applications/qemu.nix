# qemu setup using virt-manager
{ config, pkgs, inputs, user, ... }:

{

  # setup according to
  # https://nixos.wiki/wiki/Virt-manager


  # for virt-manager
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  users.groups.libvirtd.members = [user];

  users.users.${user}.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    qemu
    qemu-utils
  ];


}
