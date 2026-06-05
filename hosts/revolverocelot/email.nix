# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, sources, config, inputs, lib, pkgs, user, ... }:

let
  secrets = import "${sources.prawnix-secrets-revolverocelot}/default.nix";
  nixos-mailserver = import sources.nixos-mailserver;

in
{
  imports = [ nixos-mailserver ];

 # https://letsencrypt.org/repository/#let-s-encrypt-subscriber-agreement
  security.acme.acceptTerms = true;

  # Allow incoming HTTP connections
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Enable ACME HTTP-01 challenge with nginx
  services.nginx = {
    enable = true;
    virtualHosts.${config.mailserver.fqdn}.enableACME = true;
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.evaemmerich.com";
    domains = [ "evaemmerich.com" ];

    # Reference the existing ACME configuration created by nginx
    x509.useACMEHost = config.mailserver.fqdn;

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -s'
    accounts = {
      "eva@evaemmerich.com" = {
        # Reads the password hash from a file on the server
        #TODO!
        hashedPasswordFile = config.sops.secrets."mailserver/account/eva/password".path;
        
        # Additional addresses delivered to this mailbox
        aliases = [ "postmaster@evaemmerich.com" ];
      };
    };
  };
}
