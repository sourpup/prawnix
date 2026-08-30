{
  sources,
  self,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Hardware configuration
    "${sources.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    "${sources.nixos-pi-zero-2}/sd-image.nix"
    "${sources.nixos-pi-zero-2}/sd-defaults.nix"
    "${sources.nixos-pi-zero-2}/hardware.nix"

    # default nixos user config
    ./nixos-user.nix

    # cross compiling for arm64 is broken :p
    # (self + /modules/fish/fish.nix)

    # optional wifi on sd card config
    #(self + "modules/rpi/wifi-config.nix")
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;
  users.users.nixos.openssh.authorizedKeys.keys = [
    # TODO ssh keys here
  ];

  services.openssh = {
    enable = true;
  };

  networking = {
    hostName = "pi";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
    };
    wireless.enable = true;
  };


  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.buildPlatform = "x86_64-linux";
}
