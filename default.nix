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

  # Allow for using "${self}" to get the project path.
  outPath = ./.;


  nixosConfigurations = {
    mistral = nixos sources.nixpkgs ./hosts/mistral;
    solidsnake = nixos sources.nixpkgs ./hosts/solidsnake;
    raiden = nixos sources.nixpkgs ./hosts/raiden;
  };
}
