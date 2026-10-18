{
  config,
  lib,
  pkgs,
  zed,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;

  # Theme manifests take colours as [r g b], not hex.
  rgb =
    hex:
    map (i: lib.fromHexString (builtins.substring i 2 (lib.removePrefix "#" hex))) [
      0
      2
      4
    ];

  # Stylix's chromium target stays off (modules/theme.nix): its BrowserThemeColor
  # policy locks the Appearance section. An unpacked theme extension carries the
  # palette instead; loaded from the command line it needs no signing, and it
  # works from the read-only store. Its id is derived from the store path, so a
  # palette change installs (and applies) a new theme on the next start.
  theme = pkgs.writeTextFile {
    name = "helium-theme-zed-ayu-dark";
    destination = "/manifest.json";
    text = builtins.toJSON {
      manifest_version = 3;
      name = "Zed Ayu Dark";
      version = "1";
      theme.colors = lib.mapAttrs (_: rgb) {
        # As in Zed: the tab strip is a surface, the active tab and the toolbar
        # under it are the canvas.
        frame = zed.surface;
        frame_inactive = zed.surface;
        background_tab = zed.surface;
        toolbar = zed.canvas;
        ntp_background = zed.canvas;
        omnibox_background = zed.surface;

        tab_text = c.base05;
        tab_background_text = c.base04;
        tab_background_text_inactive = zed.disabled;
        bookmark_text = c.base05;
        toolbar_text = c.base05;
        toolbar_button_icon = c.base05;
        omnibox_text = c.base05;
        ntp_text = c.base05;
      };
    };
  };

  helium = pkgs.callPackage ../../packages/helium.nix { };
in
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Home Manager's chromium module knows no Helium, so it is a plain package with
  # its profile in ~/.config/net.imput.helium. It ships uBlock Origin itself and
  # takes extensions from its own Web Store proxy. The desktop entry runs
  # `helium` from PATH, so it gets the wrapper as well.
  home.packages = [
    (pkgs.symlinkJoin {
      inherit (helium) name meta;
      paths = [ helium ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/helium --add-flags "--load-extension=${theme}"
      '';
    })
  ];
}
