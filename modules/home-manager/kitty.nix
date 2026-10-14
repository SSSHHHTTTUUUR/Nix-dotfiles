{ pkgs, themed, ... }:

{
  home.packages = [ pkgs.kitty ];

  xdg.configFile."kitty/kitty.conf".source = themed ./config/kitty/kitty.conf;

  # kitten ssh only works inside kitty; an alias broke ssh in Zed's terminal
  # and on a TTY during recovery.
  programs.fish.functions.ssh = ''
    if set -q KITTY_WINDOW_ID; and isatty stdin
      kitten ssh $argv
    else
      command ssh $argv
    end
  '';
}
