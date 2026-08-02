# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, sources, config, inputs, lib, pkgs, user, ... }:

let

  hostname = "decoyoctopus";
  # must be one of the .nix files in modules/platform
  platform = "server";

  secrets = import "${sources.prawnix-secrets-decoyoctopus}/default.nix";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./host-tunnel.nix
      # platform specific configuration
      (self + /modules/platform/${platform}.nix)
      # secrets
      ./sops.nix
      # disko
      "${sources.disko}/module.nix"
      # application suite
      (self + /modules/applications/minimal.nix)
    ];

  # DAD delays our ability to bind our ipv6 address after network.target completes
  # disable it so our socat jobs can bind the ipv6 address immediately
  boot.kernel.sysctl = { "net.ipv6.conf.enp1s0.accept_dad" = 0; };

  networking.hostName = "${hostname}"; # Define your hostname.

  users.users.${user}.openssh.authorizedKeys.keys = secrets.auth_keys;

  services.openssh = {
    ports = [ 4422 ]; #distract the script kiddies :)
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  services.fail2ban.enable = true;

  networking = {
    interfaces = {
      enp1s0 = {
        ipv6.addresses = [{
          address = secrets.ipv6;
          prefixLength = 64;
        }];
      useDHCP = true;
    };
  };
  defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };
};

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
