{ ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts."evaemmerich.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/homepage";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
  };

}
