{
  description = "ev4s flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    # can specify a commit like this:
    #nixpkgs.url = "github:NixOS/nixpkgs?rev=8115ad8c71eca869f4af374799d52ca8a40bc1b7";
    # something in the linux-firmware bump in nixpkgs commit
    # "dd9633711ad69a86ba7771a3af9b21f453a2c707"
    # started causing system freezes due to nvme timeouts
    # these freezes usually show up by ~30 minutes after boot.
    # sometimes faster though
    # they look like:
    # Oct 03 15:29:12 mistral kernel: nvme nvme0: 16/0/0 default/read/poll queues
    # Oct 03 15:29:12 mistral kernel: nvme nvme0: Shutdown timeout set to 10 seconds
    # Oct 03 15:29:12 mistral kernel: nvme nvme0: I/O 26 QID 2 timeout, reset controller
    # Oct 03 15:28:42 mistral kernel: nvme nvme0: Abort status: 0x0
    # Oct 03 15:28:42 mistral kernel: nvme nvme0: I/O 26 (I/O Cmd) QID 2 timeout, aborting

    # pinning to the older linux-firmware package for now
    nixpkgs-mistral-firmware.url = "github:NixOS/nixpkgs?rev=5e6e5ea38b0bdf4917c0b80b7b93ad790d5299a3";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # use precreated nix-index databases for shell command not found
    #TODO as-is, this installs the database but doesn't update the command-not-found.sh
    # so we still have to run nix-locate manually
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nvix.url = "github:SolidHal/nvix";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    prawnix-secrets.url = "git+file:///home/eva/prawnix-secrets";
  };

  outputs = { self, disko, nixpkgs, nix-index-database, nixos-hardware, prawnix-secrets, nixpkgs-mistral-firmware, ... }@inputs:

  let
    # allows us to use the same devShells/package/etc definitions for multiple architectures
    # borrowed from https://ayats.org/blog/no-flake-utils
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in
  {
    nixosConfigurations.mistral = nixpkgs.lib.nixosSystem rec {
      # this lets us import modules from flakes in our other modules
      system = "x86_64-linux";
      specialArgs = {
        # including system in special args lets us use multiple versions of nixpkgs
        # reference: https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages
        user = "eva";
        inputs = inputs;
        pkgs-mistral-firmware = import nixpkgs-mistral-firmware {
            inherit system;
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

  nixosConfigurations.solidnix = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        user = "eva";
        inputs = inputs;
        primary-eth="enP4p65s0";
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
      };
      modules = [
        hosts/solidsnake/configuration.nix
        nix-index-database.nixosModules.nix-index
        disko.nixosModules.disko
      ];
    };

  nixosConfigurations.decoyoctopus = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        user = "eva";
        inputs = inputs;
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
      };
      modules = [
        hosts/decoyoctopus/configuration.nix
        disko.nixosModules.disko
      ];
    };

  nixosConfigurations.liquidsnake-build = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      # this lets us import modules from flakes in our other modules
      specialArgs = {
        user = "eva";
        inputs = inputs;
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
      };
      modules = [
        hosts/liquidsnake-build/configuration.nix
      ];
    };

    nixosConfigurations.raiden = nixpkgs.lib.nixosSystem rec {
      # this lets us import modules from flakes in our other modules
      system = "x86_64-linux";
      specialArgs = {
        # including system in special args lets us use multiple versions of nixpkgs
        # reference: https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages
        user = "eva";
        inputs = inputs;
      };
      modules = [
        hosts/raiden/configuration.nix
        nix-index-database.nixosModules.nix-index
      ];
    };

    nixosConfigurations.sunny = nixpkgs.lib.nixosSystem rec {
      # this lets us import modules from flakes in our other modules
      system = "x86_64-linux";
      specialArgs = {
        # including system in special args lets us use multiple versions of nixpkgs
        # reference: https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages
        user = "eva";
        inputs = inputs;
      };
      modules = [
        hosts/sunny/configuration.nix
        nix-index-database.nixosModules.nix-index
      ];
    };

    packages = forAllSystems (pkgs: {
        colmena-diff = pkgs.callPackage tools/colmena-diff.nix { };
    });

  };

}
