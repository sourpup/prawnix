{ user, ... }:

{
  # use wireguard config
  # start:
  # sudo systemctl start wg-quick-wg0.service
  # stop:
  # sudo systemctl stop wg-quick-wg0.service
  #
  # put the wireguard config here:
  networking.wg-quick.interfaces.wg0.configFile = "/home/${user}/wireguard/wg0.conf";
  networking.wg-quick.interfaces.wg0.autostart = false;

  # wireguard example config:
  #
  # [Interface]
  # Address = 192.168.9.X/32
  # PrivateKey = [Client's private key]
  # DNS = 192.168.9.1

  # [Peer]
  # PublicKey = [Server's public key]
  # PresharedKey = [Pre-shared key, same for server and client]
  # Endpoint = [Server Addr:Server Port]
  # AllowedIPs = 0.0.0.0/0
}
