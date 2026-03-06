# default.nix
{
  self ? (import ./. { }),
  system ? (builtins.currentSystem or null),

  sources ? (import ./lon.nix),
  nixpkgs ? sources.nixpkgs,
  #TODO figure out how to pass in config.unfree ? might just have to do it by default in hosts files
  pkgs ? (import nixpkgs { inherit system; }),
  lib ? pkgs.lib,
  ...
}@args:
let
  user = "eva";

  # a lil function to create nixos configurations
  nixos =
    nixpkgs: configuration:
    import "${nixpkgs}/nixos" {
      inherit configuration;

      # Ensure that `system` is not determined impurely.
      system = null;

      specialArgs = {
        inherit nixpkgs self sources user;
      };
    };

in
{
  inherit self sources;

  # inspired by https://somas.is/notes/organizing-nix-configuration-without-flakes/

  # TODO look at https://nix.dev/guides/recipes/dependency-management.html
  # namely we probably want
  # nix.channel.enable = false;
  # nix.nixPath = lib.mapAttrsToList (k: v: "${k}=${v}") sources;
  # AND OR https://github.com/somasis/puter/blob/46d573cb19fdab1333c6bd957ccafe5d1bbff480/modules/nixos/npins.nix
  # also check out https://jade.fyi/blog/pinning-nixos-with-npins/

  # Allow for using "${self}" to get the project path.
  outPath = ./.;


  nixosConfigurations = {
    mistral = nixos sources.nixpkgs ./hosts/mistral;
    solidsnake = nixos sources.nixpkgs ./hosts/solidsnake;
  };
}
