a multi-host flake which defines a reasonable nixos system, made up of:
- sway
- gdm
- a number of tools for settings management (wifi, bluetooth, sound, etc)
- alacritty
- zsh
- neovim (nixvim via a nvix fork)

this flake is configured for my use case, but you might find the modules helpful.
both laptop and desktop uses are considered

## Usage Instructions:
1) If you have a fresh nixos install be sure to do the following in `/etc/nixos/configuration.nix`:
  - enable flakes
  - add git
  - set your machines hostname
2) Create a <hostname>.nix file in the hosts directory. use one of the existing hosts as an example. emmerich is a desktop, mistral is a laptop
  - be sure to copy your machines `/etc/nixos/hardware-configuration.nix` to your new hosts directory
3) add a `nixosConfigurations.<hostname>` section to the `flake.nix` file
4) `sudo nixos-rebuild --flake "path-to-flake" switch` should then just work
TODO: write new host install instructions
- add git to fresh install
- enable flake/experimental features
- add host to flake .nix and to hosts
- rebuild switch flake "should" just work then
