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

    nvix.url = "github:SolidHal/nvix";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    prawnix-secrets.url = "git+file:///home/eva/prawnix-secrets";

    sops-nix = {
       url = "github:mic92/sops-nix";
       inputs.nixpkgs.follows = "nixpkgs";
     };

    prawnix-secrets-solidsnake.url = "git+file:///home/eva/prawnix-secrets-solidsnake";
    prawnix-secrets-decoyoctopus.url = "git+file:///home/eva/prawnix-secrets-decoyoctopus";
  };

  outputs = { self, disko, nixpkgs, nixos-hardware, prawnix-secrets, prawnix-secrets-solidsnake, nixpkgs-mistral-firmware, ... }@inputs:

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
    packages = forAllSystems (pkgs: {
        colmena-diff = pkgs.callPackage tools/colmena-diff.nix { };
    });

  };

}
