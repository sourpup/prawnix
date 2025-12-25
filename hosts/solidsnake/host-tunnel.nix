{ lib, pkgs, inputs, ... }:

let

wireguard_limiter = "WIREGUARD-LIMITER";
wireguard_peer_post_chain = "WIREGUARD-PEER-POST";

ignore_result = " >/dev/null 2>/dev/null || true";

docker_ipv4_subnet = "192.168.111.0/24";
docker_ipv4_address = "192.168.111.1";
wireguard_ipv4_subnet = "10.99.99.0/24";
wireguard_ipv4_address = "10.99.99.9";
wireguard_peer_ipv4_address = "10.99.99.1";

docker_ipv6_subnet = "fd31:dead:cafe::/64";
docker_ipv6_address = "fd31:dead:cafe::1";
wireguard_ipv6_subnet = "fd31:bf08:57cb::/64";
wireguard_ipv6_address = "fd31:bf08:57cb::9";
wireguard_peer_ipv6_address = "fd31:bf08:57cb::1";

in

{

  # for use with a docker compose that looks something like this
  #   # docker-compose.yml
  # services:
  #   <blah>-isolated:
  #     image: <blah>
  #     container_name: <blah>-isolated
  #     restart: unless-stopped
  #     security_opt:
  #       - no-new-privileges:true
  #     networks:
  #       - isolated
  #     dns:
  #       - fd31:bf08:57cb::1
  #       - 10.99.99.1
  #     ports:
  #       - "[fd31:bf08:57cb::9]:4480:80"
  #       - "[fd31:bf08:57cb::9]:4443:443"
  #       - "[10.99.99.9]:4480:80"
  #       - "[10.99.99.9]:4443:443"
  #     volumes:
  #
  # networks:
  #   isolated:
  #     enable_ipv6: true
  #     enable_ipv4: true
  #     driver_opts:
  #       # ensures the container doesn't use some other ip/network device if the system routes/firewall is misconfigured
  #       com.docker.network.bridge.name: isolatedbridge
  #       com.docker.network.host_ipv6: fd31:bf08:57cb::9
  #       com.docker.network.host_ipv4: 10.99.99.9
  #       com.docker.network.bridge.enable_ip_masquerade: "false"
  #       com.docker.network.driver.mtu: "1420"
  #     ipam:
  #        config:
  #          - subnet: fd31:dead:cafe::/64
  #            gateway: fd31:dead:cafe::1
  #          - subnet: 192.168.111.0/24
  #            gateway: 192.168.111.1
  #     name: isolated

  networking.firewall.allowedUDPPorts = [ 51821 ];


  # don't allow decoyoctopus to access ssh, web
  # might need something like this? https://discourse.nixos.org/t/firewall-source-destination-ips/8919/4
  networking.firewall.extraCommands = ''

  # IPV6 rules
  ip6tables -t nat  --new-chain ${wireguard_peer_post_chain};
  ip6tables -t nat -A POSTROUTING -j ${wireguard_peer_post_chain}
  ip6tables -t nat -A ${wireguard_peer_post_chain} -o wg0 -j MASQUERADE

  ip6tables --new-chain ${wireguard_limiter}
  ip6tables -A INPUT -j ${wireguard_limiter}
  ip6tables -A ${wireguard_limiter} -p ipv6-icmp -i wg0 -j ACCEPT
  ip6tables -A ${wireguard_limiter} -p tcp --dport 4443 -i wg0 -j ACCEPT
  ip6tables -A ${wireguard_limiter} -p tcp --dport 4480 -i wg0 -j ACCEPT
  ip6tables -A ${wireguard_limiter} -p udp --dport 4443 -i wg0 -j ACCEPT
  ip6tables -A ${wireguard_limiter} -p udp --dport 4480 -i wg0 -j ACCEPT
  ip6tables -A ${wireguard_limiter} -i wg0 -j DROP

  # IPV4 rules
  iptables -t nat  --new-chain ${wireguard_peer_post_chain};
  iptables -t nat -A POSTROUTING -j ${wireguard_peer_post_chain}
  iptables -t nat -A ${wireguard_peer_post_chain} -o wg0 -j MASQUERADE

  iptables --new-chain ${wireguard_limiter}
  iptables -A INPUT -j ${wireguard_limiter}
  iptables -A ${wireguard_limiter} -p ipv6-icmp -i wg0 -j ACCEPT
  iptables -A ${wireguard_limiter} -p tcp --dport 4443 -i wg0 -j ACCEPT
  iptables -A ${wireguard_limiter} -p tcp --dport 4480 -i wg0 -j ACCEPT
  iptables -A ${wireguard_limiter} -p udp --dport 4443 -i wg0 -j ACCEPT
  iptables -A ${wireguard_limiter} -p udp --dport 4480 -i wg0 -j ACCEPT
  iptables -A ${wireguard_limiter} -i wg0 -j DROP
  '';

  # clean up our chain, otherwise every rebuild just adds the rules again and again :p
  networking.firewall.extraStopCommands = ''
  ip6tables -t nat -D POSTROUTING -j ${wireguard_peer_post_chain} ${ignore_result}
  ip6tables -t nat --flush ${wireguard_peer_post_chain} ${ignore_result}
  ip6tables -t nat --delete-chain ${wireguard_peer_post_chain} ${ignore_result}

  iptables -t nat -D POSTROUTING -j ${wireguard_peer_post_chain} ${ignore_result}
  iptables -t nat --flush ${wireguard_peer_post_chain} ${ignore_result}
  iptables -t nat --delete-chain ${wireguard_peer_post_chain} ${ignore_result}

  ip6tables -D INPUT -j ${wireguard_limiter} ${ignore_result}
  ip6tables --flush ${wireguard_limiter} ${ignore_result}
  ip6tables --delete-chain ${wireguard_limiter} ${ignore_result}

  iptables -D INPUT -j ${wireguard_limiter} ${ignore_result}
  iptables --flush ${wireguard_limiter} ${ignore_result}
  iptables --delete-chain ${wireguard_limiter} ${ignore_result}
  '';



  systemd.network = {
    enable = true;

    networks."50-isolatedbridge" = {
      matchConfig.Name = "isolatedbridge";
      DHCP = "no";
      address = [
        # the isolated docker bridges address
        "${docker_ipv6_address}/64"
        "${docker_ipv4_address}/24"
      ];
      routes = [
        #
        {
          # get systemd to run
          # sudo ip -6 route add to fd31:dead:cafe::/64 dev isolatedbridge table 242
          # so the containers can talk to eachother using the bridge
          # normally, docker handles this for us by adding routes to the main table
          # but our ip rules force all packets into our table (242)
          # so we have to create our rules ourselves
          Destination = docker_ipv6_subnet;
          Table = "242";
        }
        {
          Destination = docker_ipv4_subnet;
          Table = "242";
        }
      ];
    };

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      DHCP = "no";

      address = [
        # our address on the wg network
        "${wireguard_ipv6_address}/64"
        "${wireguard_ipv4_address}/24"
      ];

      networkConfig = {
        IPv6AcceptRA = false;
        IPv6Forwarding = true;
        IPMasquerade = true;
      };

      linkConfig.RequiredForOnline = "no";

      # Manually create the only allowed route to the docker container
      # can use nmap to test that this worked properly
      routingPolicyRules = [
        #IPV6
        # tell traffic from our docker subnet to use our routing table
        {
          From = docker_ipv6_subnet;
          Table = "242";
          Priority=10;
        }
        # tell traffic from our wireguard subnet to use our routing table
        {
          From = wireguard_ipv6_subnet;
          Table = "242";
          Priority=10;
        }

        #IPV4
        # tell traffic from our docker subnet to use our routing table
        {
          From = docker_ipv4_subnet;
          Table = "242";
          Priority=10;
        }
        # tell traffic from our wireguard subnet to use our routing table
        {
          From = wireguard_ipv4_subnet;
          Table = "242";
          Priority=10;
        }

      ];

      routes = [
        {
          Gateway = wireguard_peer_ipv6_address;
          Metric = 4294967295; # heavily discourage use of this route
          Table = "242";
        }

        # ensure nothing from our docker subnet can escape if it fails to route elsewhere
        {
          Source = docker_ipv6_subnet;
          Destination = "::/0";
          Type = "blackhole";
          Metric = 3;
          Table = "242";
        }
        # route traffic from our docker subnet over the wireguard link
        {
          Gateway = wireguard_peer_ipv6_address;
          Source = docker_ipv6_subnet;
          # GatewayOnLink= true; # lets us insert the rules without the kernel complaining
          # IPv6Preference= "high";
          Table = "242";
          Metric = 2;
        }

        {
          Gateway = wireguard_peer_ipv4_address;
          Metric = 4294967295; # heavily discourage use of this route
          Table = "242";
        }

        # ensure nothing from our docker subnet can escape if it fails to route elsewhere
        {
          Source = docker_ipv4_subnet;
          Destination = "0.0.0.0/0";
          Type = "blackhole";
          Metric = 3;
          Table = "242";
        }
        # route traffic from our docker subnet over the wireguard link
        {
          Gateway = wireguard_peer_ipv4_address;
          Source = docker_ipv4_subnet;
          # GatewayOnLink= true; # lets us insert the rules without the kernel complaining
          # IPv6Preference= "high";
          Table = "242";
          Metric = 2;
        }

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
        PrivateKeyFile = inputs.prawnix-secrets.wg_decoyoctopus_privatekey;

        # we define our own routes to isolate traffic
        RouteTable = "off";
      };
      wireguardPeers = [
        {
          # laptop wg conf
          PublicKey = inputs.prawnix-secrets.wg_decoyoctopus_peer_publickey;
          AllowedIPs = [
            "::/0"
            "0.0.0.0/0"
          ];
          Endpoint = inputs.prawnix-secrets.wg_decoyoctopus_endpoint;
          PersistentKeepalive = 25;
        }
      ];
    };
  };

}
