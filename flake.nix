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
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.mistral = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # this lets us import modules from flakes (like sway-gnome) in our other modules (like configuration.nix)
      #extraSpecialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        # inputs.sway-gnome.nixosModules.default
        # inputs.regolith-nix.nixosModules.regolith
      ];
    };
  };
}
