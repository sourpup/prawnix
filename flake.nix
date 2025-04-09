{
  description = "ev4s flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixpkgs-zoom.url = "github:Yarny0/nixpkgs/zoom-fhs";

    # use precreated nix-index databases for shell command not found
    #TODO as-is, this installs the database but doesn't update the command-not-found.sh
    # so we still have to run nix-locate manually
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # use our local nvix checkout
    nvix.url = "/home/eva/repos/nvix";
  };

  outputs = { self, nixpkgs, nixpkgs-zoom, nix-index-database, ... }@inputs: {
    nixosConfigurations.mistral = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        inputs = inputs;
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
        pkgs-zoom = import nixpkgs-zoom {
            # Refer to the `system` parameter from
            # the outer scope recursively
            inherit system;
            # To use zoom, we need to allow the
            # installation of non-free software.
            config.allowUnfree = true;
        };
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
        inputs = inputs;
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
        pkgs-zoom = import nixpkgs-zoom {
            # Refer to the `system` parameter from
            # the outer scope recursively
            inherit system;
            # To use zoom, we need to allow the
            # installation of non-free software.
            config.allowUnfree = true;
        };
      };
      modules = [
        hosts/emmerich/configuration.nix
        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
