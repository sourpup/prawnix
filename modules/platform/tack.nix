{ self, sources, pkgs, nixpkgs, lib ? pkgs.lib, ... }:

let
  git = "${self.outPath}/.git";
  # by using fetchgit we get to know whether the repo is dirty or not, but we have to incur the cost of copying the repo to the store
  configRev = if builtins.pathExists git then
    let
      repo = (builtins.fetchGit self.outPath);
    in
    repo.dirtyShortRev or repo.shortRev else null;
  # most of the time that is fine, but if a copy to the store is unacceptable for some reason then
  # instead we could use the following, which can't tell us if the repo is dirty
  # if pathExists git then commitIdFromGitRepo git else null;

  lastModifiedDate = if builtins.pathExists git then
    let
      repo = (builtins.fetchGit self.outPath);
    in
    (builtins.substring 0 8 repo.lastModifiedDate) else null;


  # to perfectly emulate flakes, we would want to add all of the source we use on
  # a specific system so we can add them to the flake registry

  # this is rather hard to do without evaluating every possible source
  # evaluating every source is bad since it wastes time & disk space in the best case
  # and fails outright in the worse case, e.g. if the source is a local path that is
  # not present on this system

  # we could solve the worse case by adding a pathExists check in lon.nix before it tries to fetch,
  # but that wouldn't solve the other problems

  # realisticly, most users probably just want nixpkgs in their path/registry
  isNixpkgs = sourceName: (builtins.match ".*nixpkgs.*" sourceName != null);
  availableSources = lib.filterAttrs (name: _: isNixpkgs name) sources;

in

{

  # inspired by
  # https://somas.is/notes/organizing-nix-configuration-without-flakes/
  # https://nix.dev/guides/recipes/dependency-management.html
  # https://github.com/somasis/puter/blob/46d573cb19fdab1333c6bd957ccafe5d1bbff480/modules/nixos/npins.nix
  # https://jade.fyi/blog/pinning-nixos-with-npins/

  # disable channels since we are using nixpkgs from our pinned sources
  # suggestion from https://nix.dev/guides/recipes/dependency-management.html
  nix.channel.enable = false;

  # make pinned dependencies available as lookup paths (like <nixpkgs>)
  # Sets $NIX_PATH to our sources
  # suggestion from https://nix.dev/guides/recipes/dependency-management.html
  nix.nixPath = lib.mapAttrsToList (k: v: "${k}=${v}") availableSources;

  # Translate lon sources to Flakes in the system registry.
  nix.registry = lib.mapAttrs (_: path: {
    to = {
      type = "path";
      inherit path;
    };
  }) availableSources;

  # track revisions using git shas
  system = {
    nixos = {
      # create version in the format "25.11.date.<configSha>"
      label = (builtins.replaceStrings [ "pre" "-git" ] [ "" "" ] lib.trivial.version) + "." + lastModifiedDate + "." + configRev;
    };

    # set config repo revision like flakes
    configurationRevision = configRev;
  };


}
