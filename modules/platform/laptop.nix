# laptop platform specific configuration
{ ... }:

{
  # use power-profiles-daemon on laptops to manage battery usage
  services.power-profiles-daemon.enable = true;
}
