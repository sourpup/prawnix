{ pkgs, ... }:

let
  font_size = (pkgs.writeTextFile {
    name = "alacritty_font_size";
    text = ''

      [font]
      size = 12

    '';
  });
in

{
  imports = [
    ./default.nix

  ];

  # install alacritty config
  environment.etc = {
    "xdg/alacritty/alacritty.toml".source = (
      pkgs.concatTextFile {
        name = "alacritty.toml";
        files = [ font_size ./alacritty.toml ];
      });
  };


}
