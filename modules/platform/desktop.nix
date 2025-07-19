# desktop platform specific configuration
{ ... }:

{
  imports =
    [
      ./default.nix
    ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  #hardware.bluetooth.powerOnBoot = true;
}
