{
  lib,
  config,
  zed,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;

  # `zed` carries the UI layers (themes/zed-ui.nix, `dotfiles.theme.ui`); the semantic
  # colours are plain base16 entries, kept here.
  # Base selector for every button rule below.
  b = "button:not(.osd):not(.circular):not(.pill)";

  ui = zed // {
    text = c.base05;
    muted = c.base04;
    accent = c.base0D;
    error = c.base08;
    warning = c.base0A;
    success = c.base0B;
    shadow = "rgba(0, 0, 0, 0.5)";
  };

  css = ''
    /* ── Zed "Ayu Dark" ────────────────────────────────────────────────
       Appended after Stylix's base16 block, so these win. Loaded by
       GTK 3, GTK 4/libadwaita and, via Stylix's flatpakSupport, by the
       flattened adw-gtk3 copy Flatpak apps read.

       Three layers, as in Zed: canvas for content, surface for panels and
       dialogs, chrome for the title bar. Blue marks focus and state only. */

    /* libadwaita named colors */
    @define-color window_bg_color ${ui.surface};
    @define-color window_fg_color ${ui.text};
    @define-color view_bg_color ${ui.canvas};
    @define-color view_fg_color ${ui.text};

    @define-color headerbar_bg_color ${ui.chrome};
    @define-color headerbar_fg_color ${ui.text};
    @define-color headerbar_border_color ${ui.border};
    @define-color headerbar_backdrop_color ${ui.surface};
    @define-color headerbar_shade_color ${ui.shadow};
    @define-color headerbar_darker_shade_color ${ui.shadow};

    @define-color sidebar_bg_color ${ui.surface};
    @define-color sidebar_fg_color ${ui.text};
    @define-color sidebar_border_color ${ui.border};
    @define-color sidebar_backdrop_color ${ui.surface};
    @define-color sidebar_shade_color ${ui.shadow};
    @define-color secondary_sidebar_bg_color ${ui.surface};
    @define-color secondary_sidebar_fg_color ${ui.text};
    @define-color secondary_sidebar_border_color ${ui.border};
    @define-color secondary_sidebar_backdrop_color ${ui.surface};
    @define-color secondary_sidebar_shade_color ${ui.shadow};

    @define-color card_bg_color ${ui.surface};
    @define-color card_fg_color ${ui.text};
    @define-color card_shade_color ${ui.shadow};
    @define-color dialog_bg_color ${ui.surface};
    @define-color dialog_fg_color ${ui.text};
    @define-color popover_bg_color ${ui.surface};
    @define-color popover_fg_color ${ui.text};
    @define-color popover_shade_color ${ui.shadow};
    @define-color thumbnail_bg_color ${ui.surface};
    @define-color thumbnail_fg_color ${ui.text};
    @define-color shade_color ${ui.shadow};
    @define-color scrollbar_outline_color ${ui.border};

    @define-color accent_color ${ui.accent};
    @define-color accent_bg_color ${ui.accent};
    @define-color accent_fg_color ${ui.canvas};
    @define-color error_color ${ui.error};
    @define-color error_bg_color ${ui.errorBg};
    @define-color error_fg_color ${ui.error};
    @define-color warning_color ${ui.warning};
    @define-color warning_bg_color ${ui.warningBg};
    @define-color warning_fg_color ${ui.warning};
    @define-color success_color ${ui.success};
    @define-color success_bg_color ${ui.successBg};
    @define-color success_fg_color ${ui.success};
    @define-color destructive_color ${ui.error};
    @define-color destructive_bg_color ${ui.error};

    /* Legacy GTK 3 names — used by apps that predate libadwaita */
    @define-color theme_bg_color ${ui.surface};
    @define-color theme_fg_color ${ui.text};
    @define-color theme_base_color ${ui.canvas};
    @define-color theme_text_color ${ui.text};
    @define-color theme_selected_bg_color ${ui.selected};
    @define-color theme_selected_fg_color ${ui.text};
    @define-color theme_unfocused_bg_color ${ui.surface};
    @define-color theme_unfocused_fg_color ${ui.muted};
    @define-color theme_unfocused_base_color ${ui.canvas};
    @define-color theme_unfocused_text_color ${ui.muted};
    @define-color theme_unfocused_selected_bg_color ${ui.hover};
    @define-color theme_unfocused_selected_fg_color ${ui.text};
    @define-color insensitive_bg_color ${ui.surface};
    @define-color insensitive_fg_color ${ui.disabled};
    @define-color insensitive_base_color ${ui.canvas};
    @define-color borders ${ui.border};
    @define-color unfocused_borders ${ui.borderDisabled};
    @define-color wm_bg ${ui.chrome};
    @define-color wm_title ${ui.text};
    @define-color wm_unfocused_title ${ui.muted};
    @define-color wm_border ${ui.border};
    @define-color wm_unfocused_border ${ui.borderDisabled};
    @define-color wm_highlight ${ui.border};
    @define-color content_view_bg ${ui.canvas};
    @define-color text_view_bg ${ui.canvas};
    @define-color link_color ${ui.accent};

    /* ── Widgets ───────────────────────────────────────────────────── */

    /* Zed keeps selection neutral and spends its accent on indicators, so
       rows stay graphite instead of turning blue. */
    row:selected,
    list row:selected,
    row.activatable:selected,
    treeview.view:selected,
    treeview.view:selected:focus,
    flowboxchild:selected,
    gridview child:selected,
    columnview row:selected,
    .view:selected,
    iconview:selected,
    modelbutton:selected {
      background-color: ${ui.selected};
      color: ${ui.text};
    }

    row:hover,
    list row:hover,
    treeview.view:hover,
    flowboxchild:hover,
    modelbutton:hover,
    menuitem:hover {
      background-color: ${ui.hover};
    }

    /* Text selection: Zed's #5ac1fe3d wash, pre-resolved over the canvas */
    selection,
    *:selected:focus text selection {
      background-color: ${ui.selection};
      color: ${ui.text};
    }

    /* Chrome */
    headerbar,
    .titlebar,
    headerbar.default-decoration {
      background-color: ${ui.chrome};
      color: ${ui.text};
      border-color: ${ui.border};
      box-shadow: none;
    }

    window,
    window.background,
    .background {
      background-color: ${ui.surface};
      color: ${ui.text};
    }

    textview,
    textview text,
    .view,
    treeview.view,
    entry,
    spinbutton:not(.vertical),
    searchbar entry {
      background-color: ${ui.canvas};
      color: ${ui.text};
    }

    entry,
    spinbutton:not(.vertical) {
      border: 1px solid ${ui.border};
    }

    entry:focus {
      border-color: ${ui.accent};
      box-shadow: inset 0 0 0 1px ${ui.focusBorder};
    }

    /* GTK 3 has no :focus-within and drops a whole rule over one unknown
       selector, so this stays apart from entry:focus. */
    entry:focus-within,
    spinbutton:focus-within {
      border-color: ${ui.accent};
      box-shadow: inset 0 0 0 1px ${ui.focusBorder};
    }

    /* These rules sit at USER priority, above libadwaita and the apps' own
       styles, so OSD, circular and pill buttons (media controls, round icon
       buttons, call-to-action pills) keep their theme look. Every button rule
       carries the same :not() chain to keep specificity in step. */
    ${b} {
      background-color: ${ui.chrome};
      color: ${ui.text};
      border: 1px solid ${ui.border};
      background-image: none;
    }

    ${b}:hover {
      background-color: ${ui.hover};
    }

    ${b}:active,
    ${b}:checked,
    ${b}.flat:checked {
      background-color: ${ui.selected};
      color: ${ui.text};
    }

    ${b}.flat,
    ${b}.titlebutton,
    headerbar ${b} {
      background-color: transparent;
      border-color: transparent;
    }

    ${b}.flat:hover,
    headerbar ${b}:hover {
      background-color: ${ui.hover};
    }

    ${b}.suggested-action {
      background-color: ${ui.accent};
      color: ${ui.canvas};
      border-color: ${ui.accent};
    }

    /* A condition is a tinted wash plus its matching border, not a block. */
    ${b}.destructive-action {
      background-color: ${ui.errorBg};
      color: ${ui.error};
      border-color: ${ui.errorBorder};
    }

    popover > contents,
    popover > arrow,
    menu,
    .menu,
    .context-menu {
      background-color: ${ui.surface};
      color: ${ui.text};
      border: 1px solid ${ui.border};
      box-shadow: 0 4px 16px ${ui.shadow};
    }

    tooltip,
    tooltip.background {
      background-color: ${ui.surface};
      color: ${ui.text};
      border: 1px solid ${ui.border};
    }

    separator,
    .separator {
      background-color: ${ui.borderVariant};
      color: ${ui.borderVariant};
    }

    /* Zed's tab bar: inactive tabs sit on the surface, the active one drops
       through to the canvas.  The blue rule is the only accent. */
    notebook > header {
      background-color: ${ui.surface};
      border-color: ${ui.border};
    }

    notebook > header > tabs > tab {
      color: ${ui.muted};
      background-color: ${ui.surface};
      border-color: transparent;
    }

    notebook > header > tabs > tab:hover {
      background-color: ${ui.hover};
    }

    notebook > header > tabs > tab:checked {
      color: ${ui.text};
      background-color: ${ui.canvas};
      box-shadow: inset 0 -2px ${ui.accent};
    }

    tabbar,
    tabbar tabbox tab {
      background-color: ${ui.surface};
      color: ${ui.muted};
    }

    tabbar tabbox tab:selected {
      background-color: ${ui.canvas};
      color: ${ui.text};
      box-shadow: inset 0 -2px ${ui.accent};
    }

    /* Scrollbars: Zed's #bfbdb64c thumb, no track chrome */
    scrollbar,
    scrollbar.overlay-indicator {
      background-color: transparent;
      border-color: transparent;
    }

    scrollbar slider {
      background-color: rgba(191, 189, 182, 0.30);
      border: none;
      min-width: 6px;
      min-height: 6px;
    }

    scrollbar slider:hover {
      background-color: ${ui.muted};
    }

    scrollbar slider:active {
      background-color: ${ui.text};
    }

    /* Indicators keep the accent */
    progressbar progress,
    levelbar block.filled,
    scale highlight,
    scale > trough > highlight {
      background-color: ${ui.accent};
    }

    scale > trough,
    progressbar trough {
      background-color: ${ui.selected};
    }

    check:checked,
    radio:checked,
    check:indeterminate,
    switch:checked {
      background-color: ${ui.accent};
      color: ${ui.canvas};
      border-color: ${ui.accent};
    }

    switch {
      background-color: ${ui.selected};
    }

    label.dim-label,
    .dim-label,
    .subtitle,
    .caption {
      color: ${ui.muted};
    }

    label:disabled,
    button:disabled label,
    .dim-label:disabled {
      color: ${ui.disabled};
    }

    link,
    button.link,
    *:link {
      color: ${ui.accent};
    }

    /* Status is a tinted wash plus a matching border, as in Zed */
    infobar.error > revealer > box {
      background-color: ${ui.errorBg};
      color: ${ui.error};
      border: 1px solid ${ui.errorBorder};
    }

    infobar.warning > revealer > box {
      background-color: ${ui.warningBg};
      color: ${ui.warning};
      border: 1px solid ${ui.warningBorder};
    }

    infobar.info > revealer > box,
    infobar.question > revealer > box {
      background-color: ${ui.infoBg};
      color: ${ui.accent};
      border: 1px solid ${ui.infoBorder};
    }
  '';
in
{
  imports = [ ./lib.nix ];

  options.dotfiles.gtk.enable = lib.mkEnableOption "the Zed Ayu Dark GTK 2/3/4 and libadwaita colours on top of Stylix's GTK target";

  config = lib.mkIf config.dotfiles.gtk.enable {
    stylix.targets.gtk.extraCss = css;

    gtk = {
      # Make GTK 3 load adw-gtk3's dark stylesheet instead of recolouring the
      # light one; the colors above still override whatever it defines. Not set
      # for GTK 4: libadwaita warns on it and follows color-scheme instead.
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

      # GTK 2 ignores CSS entirely, so hand it the same palette as an rc block.
      gtk2.extraConfig = ''
        gtk-application-prefer-dark-theme = 1
        gtk_color_scheme = "fg_color:${ui.text}\nbg_color:${ui.surface}\ntext_color:${ui.text}\nbase_color:${ui.canvas}\nselected_fg_color:${ui.text}\nselected_bg_color:${ui.selected}\ntooltip_fg_color:${ui.text}\ntooltip_bg_color:${ui.surface}"
      '';
    };

  };
}
