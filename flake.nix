{
  description = "ev4s flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # dont use any flakes for now
    #sway-gnome.url = "github:SolidHal/sway-gnome-nix/main";
    #sway-gnome.url = "path:/home/eva/Documents/sway-gnome-nix";
    # force the flake to use our nixpkgs
    #sway-gnome.inputs.nixpkgs.follows = "nixpkgs";

    #TODO use some of the packages from this, but not the whole thing?
    # regolith-nix.url = "github:SolidHal/regolith-nix/main";
    # regolith-nix.inputs.nixpkgs.follows = "nixpkgs";

    # use precreated nix-index databases for shell command not found
    #TODO as-is, this installs the database but doesn't update the command-not-found.sh
    # so we still have to run nix-locate manually
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # use our local nvix checkout
    nvix.url = "/home/eva/Documents/nvix";
  };

  outputs = { self, nixpkgs, nix-index-database, ... }@inputs: {
    nixosConfigurations.mistral = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # this lets us import modules from flakes (like sway-gnome) in our other modules (like configuration.nix)
      specialArgs.inputs = inputs;
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        # inputs.sway-gnome.nixosModules.default
        # inputs.regolith-nix.nixosModules.regolith

        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
