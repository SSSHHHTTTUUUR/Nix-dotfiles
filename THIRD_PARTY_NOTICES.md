# Third-party notices

The MIT License in [LICENSE](LICENSE) covers the original code and
configuration in this repository. The following material originates elsewhere.

## Colour palette

`themes/zed-ayu-dark.yaml` and `themes/zed-ui.nix` hold the colour values of
the "Ayu Dark" theme as rendered by the [Zed](https://zed.dev) editor (Zed
Industries), which is based on [ayu](https://github.com/dempfi/ayu)
(ayu-colors v2, MIT License). Only colour values are reproduced, so that other
applications match the editor; no theme files from either project are copied.
The derived colours (for example the resolved text selection) are computed
here.

## Software configured, not included

The modules configure software installed from nixpkgs or from the core
repository; none of it is redistributed here. This includes Hyprland, hypridle,
hyprlock, Waybar, wofi, mako, kitty, wlogout, broot, fzf, Zed, Helium, cliphist,
[Stylix](https://github.com/nix-community/stylix) and
[Home Manager](https://github.com/nix-community/home-manager).

Fonts, cursors and icons selected by `nixosModules.theme` — JetBrains Mono
Nerd Font, Noto Color Emoji, Bibata cursors and the Papirus icon theme — are
installed from nixpkgs under their own licenses and are not part of this
repository.
