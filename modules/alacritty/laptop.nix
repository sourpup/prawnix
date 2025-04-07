{ pkgs, ... }:

let
  font_size_10 = (pkgs.writeTextFile {
    name = "alacritty_font_size_10_chunk";
    text = ''

      [font]
      size = 10

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
        files = [ font_size_10 ./alacritty.toml ];
      });
  };


}
