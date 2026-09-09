{ pkgs, themed, ... }:

{
  home.packages = [ pkgs.kitty ];

  xdg.configFile."kitty/kitty.conf".source = themed ./config/kitty/kitty.conf;

  programs.fish.shellAliases.ssh = "kitten ssh";
}
