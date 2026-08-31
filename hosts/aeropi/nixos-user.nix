{ ... }:
{
  
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    # default password should be changed
    password = "nixos";
  };

  # Allow passwordless sudo from nixos user
  security.sudo = {
    enable = true;
  };

  # allow nix-copy to live system
  nix.settings.trusted-users = [ "nixos" ];

}
