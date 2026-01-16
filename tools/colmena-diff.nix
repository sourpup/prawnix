{
  writers,
  nix-diff,
  lib,
  ...
}:

# diff the environment we would like to deploy, against
# the current running environment
# written as an quick answer to https://github.com/zhaofengli/colmena/issues/64
# local drv comparison borrowed from https://forkspace.net/leona/nixfiles/-/blob/main/packages/nix-eval-and-diff/default.nix

writers.writePython3Bin "colmena-diff" { doCheck = false; } ''
  import subprocess
  import random
  import string
  import json
  from pathlib import Path
  import argparse

  parser = argparse.ArgumentParser(prog="colmena-diff")
  parser.add_argument("hostname")
  args = parser.parse_args()

  def eval_(hostname: str, cwd: Path):
      drvs = json.loads(
          subprocess.check_output(
              [
                  "nix",
                  "path-info",
                  "--derivation",
                  f".#nixosConfigurations.{hostname}.config.system.build.toplevel",
                  "--json",
              ],
              cwd=cwd,
              text=True,
              stderr=subprocess.DEVNULL,
          )
      )
      # Nix and Lix behave differently here:
      # Nix returns a dict of drvs, Lix a list of dicts
      if isinstance(drvs, list):
        return drvs[0]["path"]
      elif isinstance(drvs, dict):
        return list(drvs.keys())[0]

  def _current_remote_sha(hostname: str, cwd: Path):
      # note, this value is likely dependent on how flakes define the nixos
      # version by appending the sha of the flake repo
      # if/when we move away from flakes, this will have to be determined some other way

      # results in something of the form:
      # hostname |
      # hostname | 26.05.719f19e-06e36ff
      # hostname | Succeeded
      #          | All done!
      output = subprocess.check_output(
        [
            "nix",
            "run",
            ".#colmena",
            "--",
            "exec",
            "--verbose", # without this, we don't see any output of the command
            "--on",
            hostname,
            "--",
            "cat",
            "/run/current-system/nixos-version",
        ],
        cwd=cwd,
        text=True,
        stderr=subprocess.STDOUT, # because colmena is dumb and only prints the command result over stderr
      )

      # because the only options are
      # no output, or *verbose*
      # colmena spams us with lots of stuff we don't care about
      for line in output.splitlines():
        # lazy check for this line
        # hostname | 26.05.719f19e-06e36ff
        # we could be more clever, since version
        # is a known format but this works well enough
        # remove the hostname to ensure things like "my-hostname" dont mess up the dash match
        print(line)
        if hostname in line and "-" in line.removeprefix(hostname):
          return line.removeprefix(hostname).split("-")[1]

      raise RuntimeError(f"unable to find sha in colmena output: {output}")

  base_path = Path(
      subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
  )
  random_string = "".join(random.choices(string.ascii_letters + string.digits, k=6))
  worktree_path = base_path / f".worktree/eval-and-diff-{random_string}"

  remote_sha = _current_remote_sha(args.hostname, base_path)
  print(f"found remote sha {remote_sha}")

  subprocess.run(
      ["git", "worktree", "add", worktree_path, remote_sha],
      cwd=base_path,
      check=True,
  )
  main_drv = eval_(args.hostname, worktree_path)
  subprocess.run(
      ["git", "worktree", "remove", worktree_path],
      cwd=base_path,
      check=True,
  )
  new_drv = eval_(args.hostname, base_path)

  print(
      subprocess.check_output(
          ["${lib.getExe nix-diff}", "--color", "always", main_drv, new_drv],
          text=True,
      )
  )
''
