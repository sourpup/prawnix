{ pkgs, lib, ... }:
let
  helix-overlay = final: prev: {
    helix = pkgs.symlinkJoin {
      name = "helix";
      paths = [ prev.helix ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hx --set XDG_CONFIG_HOME "/etc/xdg/"
      '';
    };
  };
in
{

  nixpkgs.overlays = [ helix-overlay ];
  environment.systemPackages = [
    pkgs.helix
  ];

  environment.variables.EDITOR = "hx";
  environment.variables.VISUAL = "hx";

  environment.etc = {
    "xdg/helix/config.toml".text = ''
      # also consider "flatwhite" or "kaolin-light"
      theme = "rose_pine_dawn"

      #TODO test copy & paste across ssh
      #
      #  Note: Helix doesn't share the system clipboard by default. Type
      #     Space + y / p to yank / paste on the system's clipboard.

      # settings at https://docs.helix-editor.com/master/editor.html
      [editor]
      mouse = true
      line-number = "relative"
      end-of-line-diagnostics = "hint"
      true-color = true

      [editor.cursor-shape]
      insert = "bar"
      normal = "block"
      select = "underline"

      [editor.file-picker]
      hidden = false

      [editor.soft-wrap]
      enable = true

      [editor.lsp]
      display-inlay-hints = true

      # not yet available in 25.07.1, which is the latest release
      # auto-document-highlight = true

      [editor.inline-diagnostics]
      cursor-line = "warning"
      other-lines = "warning"

      [keys.normal]
      # vim visual line select
      V = ["select_mode", "extend_to_line_bounds"]
      # aka "ge" by default
      G = "goto_file_end"
    '';
  };

  environment.etc = {
    "xdg/helix/languages.toml".text = ''
      [language-server.nix]
      command = "nixd"

      [[language]]
      name = "nix"
      formatter = { command = "nixfmt" }
    '';
  };

}
