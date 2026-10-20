# Shared by every module here: the Zed UI palette and the `themed` template
# helper, handed to modules as the `zed`, `themed` and `themedWith` arguments.
# Each module imports this file; the module system loads it once.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # The base16 palette comes from Stylix, so the Stylix Home Manager module
  # must be loaded (the Stylix NixOS module loads it for every user).
  colors = config.lib.stylix.colors;
  palette = {
    inherit (colors)
      base00
      base01
      base02
      base03
      base04
      base05
      base06
      base07
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      base0F
      ;
  };

  zed = config.dotfiles.theme.ui;

  # `borderVariant` -> `border_variant`, so templates read `#@zed_border_variant@`
  # the same way as `#@base05@`.
  toSnakeCase =
    name:
    lib.concatStrings (
      map (part: if builtins.isList part then "_" + lib.toLower (builtins.head part) else part) (
        builtins.split "([A-Z])" name
      )
    );

  zedVars = lib.mapAttrs' (
    name: value: lib.nameValuePair "zed_${toSnakeCase name}" (lib.removePrefix "#" value)
  ) zed;

  templateVars =
    palette
    // zedVars
    // {
      # `null` keeps a placeholder as it is: hyprland.lua and the Waybar config
      # use @DEFAULT_AUDIO_SINK@ as wpctl syntax.
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
      # Hyprland's own cursor size must match the one Stylix gives GTK, or the
      # pointer changes size on window borders.
      cursor_size = toString config.stylix.cursor.size;
    };

  # replaceVars fails on a variable that does not occur in the file, so the set
  # is first filtered down to the placeholders that `src` actually contains.
  themedWith =
    extraVars: src:
    let
      vars = templateVars // extraVars;
    in
    pkgs.replaceVars src (
      lib.filterAttrs (name: _: lib.hasInfix "@${name}@" (builtins.readFile src)) vars
    );
in
{
  # Zed's "Ayu Dark" UI roles base16 has no slot for; see themes/zed-ui.nix.
  # Every key is a separate default, so one colour can be overridden alone:
  #   dotfiles.theme.ui.surface = "#202020";
  options.dotfiles.theme.ui = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    description = ''
      The interface palette (canvas, surface, chrome, hover, selected, borders,
      tinted semantic backgrounds) used next to the Stylix base16 scheme.
      Templates read it as `@zed_<snake_case_name>@`.
    '';
  };

  config = {
    dotfiles.theme.ui = lib.mapAttrs (_: lib.mkDefault) (import ../../themes/zed-ui.nix);

    _module.args = {
      inherit zed themedWith;
      themed = themedWith { };
    };
  };
}
