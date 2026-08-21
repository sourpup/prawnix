{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.tofi
  ];

  # set up our menu/launcher
  environment.etc = {
    "xdg/tofi/tofi-config".source = ./tofi-config;
  };

  # tofi fails to regenerate its cache properly on nixos
  # https://github.com/philj56/tofi/issues/115
  system.userActivationScripts.regenerateTofiCache.text = ''
    if [[ -d $XDG_CACHE_HOME ]]; then
      tofi_cache=$XDG_CACHE_HOME/tofi-drun
    else
      tofi_cache=$HOME/.cache/tofi-drun
    fi
    [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
  '';

}
