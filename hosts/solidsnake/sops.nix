{ self, sources, ... }:
let
  secrets = import "${sources.prawnix-secrets-solidsnake}/default.nix";
in
{
  imports = [
    "${sources.sops-nix}/modules/sops"
  ];

  sops = {
    defaultSopsFile = secrets.secretsFile;

    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "wireguard/decoyoctopus/peer_publickey" = {
        owner = "root";
        group = "systemd-network";
        mode = "0640";
      };
      "wireguard/decoyoctopus/privatekey" = {
        owner = "root";
        group = "systemd-network";
        mode = "0640";
      };
      "nut/admin_password" = {
        owner = "root";
        mode = "0640";
      };
      "nut/email_msmtp_conf" = {
        owner = "nutmon";
        mode = "0600";
      };
      "borg/email_msmtp_conf" = {
        owner = "root";
        mode = "0600";
      };
    };
  };
 }
