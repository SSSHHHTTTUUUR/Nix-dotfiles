{ ... }:

let
  # Palette taken from Zed's "Ayu Dark" (ayu-colors v2).  Only the values that
  # base16 has no slot for live here; everything else comes from
  # modules/themes/zed-ayu-dark.yaml through Stylix.
  zed = {
    canvas = "#0b0e14"; # editor.bg      — text views, lists, entries
    window = "#0d1017"; # ui.bg          — window chrome
    panel = "#0f131a"; # ui.panel.bg    — header bars, sidebars, popovers
    raised = "#11151c"; # ui.line        — cards, raised rows
    hover = "#131721"; # editor.line    — hover feedback
    selected = "#1a1f29"; # ui.selection   — selected rows / active element
    border = "#1b1f26"; # panel borders
    text = "#bfbdb6"; # editor.fg
    dim = "#565b66"; # ui.fg          — dimmed labels, scrollbars
    dimmer = "#8a9199";
    accent = "#e6b450"; # common.accent  — ayu amber
    link = "#59c2ff"; # syntax.entity
    error = "#d95757"; # common.error
    shadow = "rgba(0, 0, 0, 0.5)"; # ui.panel.shadow
  };

  css = ''
    /* ── Zed "Ayu Dark" ────────────────────────────────────────────────
       Appended after Stylix's base16 block, so these win.  Loaded by
       GTK 3, GTK 4/libadwaita and (via Stylix's flatpakSupport) by the
       flattened adw-gtk3 copy that Flatpak apps read. */

    /* libadwaita named colors */
    @define-color window_bg_color ${zed.window};
    @define-color window_fg_color ${zed.text};
    @define-color view_bg_color ${zed.canvas};
    @define-color view_fg_color ${zed.text};

    @define-color headerbar_bg_color ${zed.panel};
    @define-color headerbar_fg_color ${zed.text};
    @define-color headerbar_border_color ${zed.border};
    @define-color headerbar_backdrop_color ${zed.window};
    @define-color headerbar_shade_color ${zed.shadow};
    @define-color headerbar_darker_shade_color ${zed.shadow};

    @define-color sidebar_bg_color ${zed.panel};
    @define-color sidebar_fg_color ${zed.text};
    @define-color sidebar_border_color ${zed.border};
    @define-color sidebar_backdrop_color ${zed.window};
    @define-color sidebar_shade_color ${zed.shadow};
    @define-color secondary_sidebar_bg_color ${zed.window};
    @define-color secondary_sidebar_fg_color ${zed.text};
    @define-color secondary_sidebar_border_color ${zed.border};
    @define-color secondary_sidebar_backdrop_color ${zed.window};
    @define-color secondary_sidebar_shade_color ${zed.shadow};

    @define-color card_bg_color ${zed.raised};
    @define-color card_fg_color ${zed.text};
    @define-color card_shade_color ${zed.shadow};
    @define-color dialog_bg_color ${zed.panel};
    @define-color dialog_fg_color ${zed.text};
    @define-color popover_bg_color ${zed.panel};
    @define-color popover_fg_color ${zed.text};
    @define-color popover_shade_color ${zed.shadow};
    @define-color thumbnail_bg_color ${zed.raised};
    @define-color thumbnail_fg_color ${zed.text};
    @define-color shade_color ${zed.shadow};
    @define-color scrollbar_outline_color ${zed.border};

    @define-color accent_color ${zed.accent};
    @define-color accent_bg_color ${zed.accent};
    @define-color accent_fg_color ${zed.canvas};
    @define-color error_color ${zed.error};
    @define-color error_bg_color ${zed.error};
    @define-color destructive_color ${zed.error};
    @define-color destructive_bg_color ${zed.error};

    /* Legacy GTK 3 names — used by apps that predate libadwaita */
    @define-color theme_bg_color ${zed.window};
    @define-color theme_fg_color ${zed.text};
    @define-color theme_base_color ${zed.canvas};
    @define-color theme_text_color ${zed.text};
    @define-color theme_selected_bg_color ${zed.selected};
    @define-color theme_selected_fg_color ${zed.text};
    @define-color theme_unfocused_bg_color ${zed.window};
    @define-color theme_unfocused_fg_color ${zed.dimmer};
    @define-color theme_unfocused_base_color ${zed.canvas};
    @define-color theme_unfocused_text_color ${zed.dimmer};
    @define-color theme_unfocused_selected_bg_color ${zed.raised};
    @define-color theme_unfocused_selected_fg_color ${zed.text};
    @define-color insensitive_bg_color ${zed.window};
    @define-color insensitive_fg_color ${zed.dim};
    @define-color insensitive_base_color ${zed.canvas};
    @define-color borders ${zed.border};
    @define-color unfocused_borders ${zed.raised};
    @define-color wm_bg ${zed.panel};
    @define-color wm_title ${zed.text};
    @define-color wm_unfocused_title ${zed.dim};
    @define-color wm_border ${zed.border};
    @define-color wm_unfocused_border ${zed.raised};
    @define-color wm_highlight ${zed.border};
    @define-color content_view_bg ${zed.canvas};
    @define-color text_view_bg ${zed.canvas};
    @define-color link_color ${zed.link};

    /* ── Widgets ───────────────────────────────────────────────────── */

    /* Zed keeps selection neutral and spends its accent on indicators, so
       rows stay grey-blue instead of turning amber. */
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
      background-color: ${zed.selected};
      color: ${zed.text};
    }

    row:hover,
    list row:hover,
    treeview.view:hover,
    flowboxchild:hover,
    modelbutton:hover,
    menuitem:hover {
      background-color: ${zed.hover};
    }

    /* Text selection: ayu's translucent blue wash */
    selection,
    *:selected:focus text selection {
      background-color: rgba(64, 159, 255, 0.30);
      color: ${zed.text};
    }

    /* Chrome */
    headerbar,
    .titlebar,
    headerbar.default-decoration {
      background-color: ${zed.panel};
      color: ${zed.text};
      border-color: ${zed.border};
      box-shadow: none;
    }

    window,
    window.background,
    .background {
      background-color: ${zed.window};
      color: ${zed.text};
    }

    textview,
    textview text,
    .view,
    treeview.view,
    entry,
    spinbutton:not(.vertical),
    searchbar entry {
      background-color: ${zed.canvas};
      color: ${zed.text};
    }

    entry,
    spinbutton:not(.vertical) {
      border: 1px solid ${zed.border};
    }

    entry:focus,
    entry:focus-within,
    spinbutton:focus-within {
      border-color: ${zed.link};
      box-shadow: inset 0 0 0 1px ${zed.link};
    }

    button {
      background-color: ${zed.raised};
      color: ${zed.text};
      border: 1px solid ${zed.border};
      background-image: none;
    }

    button:hover {
      background-color: ${zed.selected};
    }

    button:active,
    button:checked {
      background-color: ${zed.border};
      color: ${zed.text};
    }

    button.flat,
    button.titlebutton,
    headerbar button {
      background-color: transparent;
      border-color: transparent;
    }

    button.flat:hover,
    headerbar button:hover {
      background-color: ${zed.hover};
    }

    button.suggested-action {
      background-color: ${zed.accent};
      color: ${zed.canvas};
      border-color: ${zed.accent};
    }

    button.destructive-action {
      background-color: ${zed.error};
      color: ${zed.canvas};
      border-color: ${zed.error};
    }

    popover > contents,
    popover > arrow,
    menu,
    .menu,
    .context-menu {
      background-color: ${zed.panel};
      color: ${zed.text};
      border: 1px solid ${zed.border};
      box-shadow: 0 4px 16px ${zed.shadow};
    }

    tooltip,
    tooltip.background {
      background-color: ${zed.panel};
      color: ${zed.text};
      border: 1px solid ${zed.border};
    }

    separator,
    .separator {
      background-color: ${zed.border};
      color: ${zed.border};
    }

    /* Active tab gets ayu's amber underline, like Zed's tab bar */
    notebook > header {
      background-color: ${zed.window};
      border-color: ${zed.border};
    }

    notebook > header > tabs > tab {
      color: ${zed.dim};
      background-color: transparent;
      border-color: transparent;
    }

    notebook > header > tabs > tab:checked {
      color: ${zed.text};
      background-color: ${zed.canvas};
      box-shadow: inset 0 -2px ${zed.accent};
    }

    tabbar tabbox tab:checked {
      background-color: ${zed.canvas};
      color: ${zed.text};
      box-shadow: inset 0 -2px ${zed.accent};
    }

    /* Scrollbars: thin, grey, no track chrome */
    scrollbar,
    scrollbar.overlay-indicator {
      background-color: transparent;
      border-color: transparent;
    }

    scrollbar slider {
      background-color: ${zed.dim};
      border: none;
      min-width: 6px;
      min-height: 6px;
    }

    scrollbar slider:hover {
      background-color: ${zed.dimmer};
    }

    scrollbar slider:active {
      background-color: ${zed.text};
    }

    /* Indicators keep the accent */
    progressbar progress,
    levelbar block.filled,
    scale highlight,
    scale > trough > highlight {
      background-color: ${zed.accent};
    }

    scale > trough,
    progressbar trough {
      background-color: ${zed.selected};
    }

    check:checked,
    radio:checked,
    check:indeterminate,
    switch:checked {
      background-color: ${zed.accent};
      color: ${zed.canvas};
      border-color: ${zed.accent};
    }

    switch {
      background-color: ${zed.selected};
    }

    label.dim-label,
    .dim-label,
    .subtitle,
    .caption {
      color: ${zed.dim};
    }

    label:disabled,
    button:disabled label,
    .dim-label:disabled {
      color: ${zed.dim};
    }

    link,
    button.link,
    *:link {
      color: ${zed.link};
    }

    infobar.error > revealer > box {
      background-color: ${zed.error};
      color: ${zed.canvas};
    }
  '';
in
{
  stylix.targets.gtk.extraCss = css;

  gtk = {
    # Make GTK 3 load adw-gtk3's dark stylesheet instead of recolouring the
    # light one; the colors above still override whatever it defines.
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

    # GTK 2 ignores CSS entirely, so hand it the same palette as an rc block.
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1
      gtk_color_scheme = "fg_color:${zed.text}\nbg_color:${zed.window}\ntext_color:${zed.text}\nbase_color:${zed.canvas}\nselected_fg_color:${zed.text}\nselected_bg_color:${zed.selected}\ntooltip_fg_color:${zed.text}\ntooltip_bg_color:${zed.panel}"
    '';
  };

}
