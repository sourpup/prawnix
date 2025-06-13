{
  description = "ev4s flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # use precreated nix-index databases for shell command not found
    #TODO as-is, this installs the database but doesn't update the command-not-found.sh
    # so we still have to run nix-locate manually
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nvix.url = "github:SolidHal/nvix";
  };

  outputs = { self, nixpkgs, nix-index-database, nixos-hardware, ... }@inputs: {
    nixosConfigurations.mistral = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        user = "eva";
        inputs = inputs;
      };
      modules = [
        hosts/mistral/configuration.nix
        nix-index-database.nixosModules.nix-index
      ];
    };

    nixosConfigurations.emmerich = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        user = "eva";
        inputs = inputs;
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
      };
      modules = [
        hosts/emmerich/configuration.nix
        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
