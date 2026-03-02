{ inputs, ... }:
let
  secrets = inputs.prawnix-secrets-decoyoctopus;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = secrets.secretsFile;

    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "wireguard/solidsnake/peer_publickey" = {
        owner = "root";
        group = "systemd-network";
        mode = "0640";
      };
      "wireguard/solidsnake/privatekey" = {
        owner = "root";
        group = "systemd-network";
        mode = "0640";
      };
    };
  };
 }
