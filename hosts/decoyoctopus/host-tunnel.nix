{ self, sources, config, lib, pkgs, inputs, ... }:

let

ignore_result = " >/dev/null 2>/dev/null || true";

wireguard_peer_post_chain = "WIREGUARD-PEER-POST";
wireguard_peer_input_chain = "WIREGUARD-PEER-INPUT";

wireguard_ipv6 = "fd31:bf08:57cb::1"; # our ip on the wireguard network
wireguard_ipv4 = "10.99.99.1";
wireguard_peer_ipv6 = "fd31:bf08:57cb::9"; # our peers ip on the wireguard network
wireguard_peer_ipv4 = "10.99.99.9";

secrets = import "${sources.prawnix-secrets-decoyoctopus}/default.nix";

socat_service = { in_port, out_port }: ({
      wantedBy = [ "multi-user.target" ];
      after = [ "firewall.service" "network.target" ];
      description = "forward ipv4 port ${in_port} to ipv4 port ${out_port}";
        serviceConfig = {
          ExecStart = "${pkgs.socat}/bin/socat -d3 TCP4-LISTEN:${in_port},fork,su=nobody,reuseaddr,bind=${secrets.ipv4} 'TCP4:[${wireguard_peer_ipv4}]:${out_port}'";
        };
    });

socat6_service = { in_port, out_port }: ({
      wantedBy = [ "multi-user.target" ];
      after = [ "firewall.service" "network.target" ];
      description = "forward ipv6 port ${in_port} to ipv6 port ${out_port}";
        serviceConfig = {
          ExecStart = "${pkgs.socat}/bin/socat -d3 TCP6-LISTEN:${in_port},fork,su=nobody,reuseaddr,bind=${secrets.ipv6} 'TCP6:[${wireguard_peer_ipv6}]:${out_port}'";
        };
    });

in
{

  networking.useNetworkd = true;
  # dont use networkmanager on server
  networking.networkmanager.enable = lib.mkForce false;

  networking.firewall.allowedUDPPorts = [ 51821 ];
  networking.firewall.allowedTCPPorts = [ 80 443 22 ];

  # enable ip forwarding so we can route packets
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  environment.systemPackages = with pkgs; [
    socat
  ];


  networking.firewall.extraCommands = ''
  # IPV6 rules
  # enable MASQUERADE from wg0
  ip6tables -t nat  --new-chain ${wireguard_peer_post_chain};
  ip6tables -t nat -A POSTROUTING -j ${wireguard_peer_post_chain}
  ip6tables -t nat -A ${wireguard_peer_post_chain} -i wg0 -o enp1s0 -j MASQUERADE

  # allow dns lookups from wg0
  ip6tables  --new-chain ${wireguard_peer_input_chain};
  ip6tables  -A INPUT -j ${wireguard_peer_input_chain}
  ip6tables  -A ${wireguard_peer_input_chain} -i wg0 -p tcp --dport 53 -j ACCEPT
  ip6tables  -A ${wireguard_peer_input_chain} -i wg0 -p udp --dport 53 -j ACCEPT

  # IPV4 rules
  # enable MASQUERADE from wg0
  iptables -t nat  --new-chain ${wireguard_peer_post_chain};
  iptables -t nat -A POSTROUTING -j ${wireguard_peer_post_chain}
  iptables -t nat -A ${wireguard_peer_post_chain} -i wg0 -o enp1s0 -j MASQUERADE

  # allow dns lookups from wg0
  iptables  --new-chain ${wireguard_peer_input_chain};
  iptables  -A INPUT -j ${wireguard_peer_input_chain}
  iptables  -A ${wireguard_peer_input_chain} -i wg0 -p tcp --dport 53 -j ACCEPT
  iptables  -A ${wireguard_peer_input_chain} -i wg0 -p udp --dport 53 -j ACCEPT
  '';

  # clean up our chains, otherwise every rebuild just adds the rules again and again :p
  # have to use ${ignore_result} otherwise the rebuild will fail if these chains dont already exist
  networking.firewall.extraStopCommands = ''
  # Remove IPV4 chains
  iptables -t nat -D POSTROUTING -j ${wireguard_peer_post_chain} ${ignore_result}
  iptables -t nat --flush ${wireguard_peer_post_chain} ${ignore_result}
  iptables -t nat --delete-chain ${wireguard_peer_post_chain} ${ignore_result}

  iptables -D INPUT -j ${wireguard_peer_input_chain} ${ignore_result}
  iptables --flush ${wireguard_peer_input_chain} ${ignore_result}
  iptables --delete-chain ${wireguard_peer_input_chain} ${ignore_result}

  # Remove IPV6 chains
  ip6tables -t nat -D POSTROUTING -j ${wireguard_peer_post_chain} ${ignore_result}
  ip6tables -t nat --flush ${wireguard_peer_post_chain} ${ignore_result}
  ip6tables -t nat --delete-chain ${wireguard_peer_post_chain} ${ignore_result}

  ip6tables -D INPUT -j ${wireguard_peer_input_chain} ${ignore_result}
  ip6tables --flush ${wireguard_peer_input_chain} ${ignore_result}
  ip6tables --delete-chain ${wireguard_peer_input_chain} ${ignore_result}
  '';

  services.resolved.settings.Resolve = {
    DNSStubListener=true;
    DNSStubListenerExtra=["${wireguard_ipv4}" "${wireguard_ipv6}"];
  };

  systemd = {

    services.socat-tunnel-port-80 = socat_service { in_port="80"; out_port="4480"; };
    services.socat-tunnel-port-443 = socat_service { in_port="443"; out_port="4443"; };
    services.socat-tunnel-port-22 = socat_service { in_port="22"; out_port="222"; };

    services.socat6-tunnel-port-80 = socat6_service { in_port="80"; out_port="4480"; };
    services.socat6-tunnel-port-443 = socat6_service { in_port="443"; out_port="4443"; };
    services.socat6-tunnel-port-22 = socat6_service { in_port="22"; out_port="222"; };


    network = {
      enable = true;

      networks."50-wg0" = {
        matchConfig.Name = "wg0";

        address = [
          # /32 and /128 specifies a single address
          # for use on this wg peer machine
          "${wireguard_ipv6}/128"
          "${wireguard_ipv4}/32"
        ];
      };

      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };

        wireguardConfig = {
          ListenPort = 51821;

          # ensure file is readable by `systemd-network` user
          PrivateKeyFile = config.sops.secrets."wireguard/solidsnake/privatekey".path;


          # Automatically create routes for everything in AllowedIPs
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            # solidsnake wg conf
            PublicKeyFile = config.sops.secrets."wireguard/solidsnake/peer_publickey".path;

            AllowedIPs = [
               "${wireguard_peer_ipv6}/128"
               "${wireguard_peer_ipv4}/32"
            ];

            Endpoint = secrets.wireguard.solidsnake.endpoint;
          }
        ];
      };
    };
  };

}
