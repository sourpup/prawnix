# server platform specific configuration
{ pkgs, initrdssh-netdev-name, ... }:

{

  imports = [
      ./default.nix
  ];

  services.openssh.enable = true;

  # initrd ssh for LUKS boot drive decrypt
  boot.initrd = {
    # Enable systemd in the initial ramdisk environment
    systemd = {
      enable = true;
      # Specify which programs need to be available during early boot
      initrdBin = with pkgs; [
        cryptsetup  # Tool needed for unlocking LUKS encrypted drives
      ];

      # Configure networking using systemd's network manager
      network = {
        networks = {
          ${initrdssh-netdev-name} = {
            matchConfig = {
              Name = initrdssh-netdev-name;  # Matches the network interface by name
            };
            networkConfig = {
              DHCP = "yes";  # Enable DHCP to automatically get an IP address
            };
          };
        };
      };
    };

    # Configure SSH access during early boot
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;  # Use a non-standard port to differentiate from a running systems ssh server

        # Only allow running the default systemd boot path in initrd
        authorizedKeys = [
          ''command="systemctl default" [SSHKey]''
        ];
        # Location of the SSH host key
        hostKeys = [ /etc/ssh/initrd_ssh_host_ed25519_key ];
      };
    };
  };

}
