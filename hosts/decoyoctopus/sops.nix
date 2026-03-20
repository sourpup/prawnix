{ sources,  ... }:
let
  secrets = import "${sources.prawnix-secrets-decoyoctopus}/default.nix";
in
{
  imports = [
    "${sources.sops-nix}/modules/sops"
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
