{ inputs, ... }:
let
  secrets = inputs.prawnix-secrets-solidsnake;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
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
    };
  };
 }
