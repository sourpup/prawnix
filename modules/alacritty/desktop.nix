{ pkgs, ... }:

let
  font_size_12 = (pkgs.writeTextFile {
    name = "alacritty_font_size_12_chunk";
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
        files = [ font_size_12 ./alacritty.toml ];
      });
  };


}
