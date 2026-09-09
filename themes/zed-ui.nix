# Zed's "Ayu Dark" UI roles that base16 has no slot for: base16 carries a
# single selection colour, while Zed distinguishes chrome, hover, selected and
# three kinds of border.  base16 (zed-ayu-dark.yaml) stays the portable colour
# scheme and carries syntax and semantics; this is the precise UI palette.
#
# Both layers read it: Home Manager passes it to its modules as the `zed`
# argument (home/tea/default.nix), the system side imports it directly
# (modules/chromium.nix).
{
  canvas = "#0d1016"; # editor / terminal background — same as base00
  surface = "#1f2127"; # panels, tab bar, popovers, notifications
  chrome = "#313337"; # title bar / status bar

  hover = "#2d2f34"; # hover feedback
  selected = "#3e4043"; # selected / active element — same as base02

  border = "#3f4043";
  borderVariant = "#2d2f34"; # quieter divider inside a surface
  borderDisabled = "#383a3e";
  focusBorder = "#1b4a6e";

  disabled = "#696a6a";

  # Tinted semantic backgrounds: Zed states a condition with a wash plus a
  # matching border, never with a saturated fill.
  successBg = "#294113";
  successBorder = "#405c1c";
  warningBg = "#572815";
  warningBorder = "#754221";
  errorBg = "#48161b";
  errorBorder = "#66272d";
  infoBg = "#0d2f4e";
  infoBorder = "#1b4a6e";

  # Zed's #5ac1fe3d text selection resolved against the canvas.
  selection = "#1f3a4d";
}
