# Every Home Manager module of this repository. Importing it enables nothing on
# its own: turn on `dotfiles.desktop.enable` for the whole Hyprland desktop, or
# individual `dotfiles.<module>.enable` options.
{ config, lib, ... }:

let
  desktopModules = [
    "clipboard"
    "gtk"
    "hyprland"
    "kitty"
    "mako"
    "waybar"
    "wlogout"
    "wofi"
  ];
in
{
  imports = [
    ./broot.nix
    ./clipboard.nix
    ./fzf.nix
    ./gtk.nix
    ./helium.nix
    ./hyprland.nix
    ./kitty.nix
    ./lib.nix
    ./mako.nix
    ./waybar.nix
    ./wlogout.nix
    ./wofi.nix
    ./zed-editor.nix
  ];

  options.dotfiles.desktop.enable = lib.mkEnableOption ''
    the Hyprland desktop: ${lib.concatStringsSep ", " desktopModules}.
    Each stays individually switchable through its own enable option
  '';

  config = lib.mkIf config.dotfiles.desktop.enable {
    dotfiles = lib.genAttrs desktopModules (_: {
      enable = lib.mkDefault true;
    });
  };
}
