{ config, zed, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.broot = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      # -s: recursive size column; -h: keep hidden visible (as the yazi setup
      # this replaced did).
      #
      # --sort-by-type-dirs-first pins broot to one tree level — directories
      # only expand on demand, list style like yazi. A search still walks the
      # whole subtree; only the idle view is flat.
      default_flags = "-sh --sort-by-type-dirs-first";

      # Dark base16 theme for the syntax-highlighted file preview.
      syntax_theme = "OceanDark";

      # "fg bg attributes / same for the unfocused panel"
      skin = {
        default = "${c.base05} ${c.base00}";
        tree = "${c.base02} none";
        parent = "${c.base04} none";
        file = "${c.base05} none";
        directory = "${c.base0D} none bold";
        exe = "${c.base0B} none";
        link = "${c.base0C} none";
        pruning = "${c.base03} none italic";

        perm__ = "${c.base03} none";
        perm_r = "${c.base0A} none";
        perm_w = "${c.base08} none";
        perm_x = "${c.base0B} none";
        owner = "${c.base04} none";
        group = "${c.base04} none";

        count = "${c.base0C} ${c.base01}";
        dates = "${c.base03} none";
        sparse = "${c.base09} none";

        content_extract = "${c.base0C} none italic";
        content_match = "${c.base0A} none bold";

        git_branch = "${c.base0E} none";
        git_insertions = "${c.base0B} none";
        git_deletions = "${c.base08} none";
        git_status_current = "${c.base03} none";
        git_status_modified = "${c.base0A} none";
        git_status_new = "${c.base0B} none bold";
        git_status_ignored = "${c.base03} none";
        git_status_conflicted = "${c.base08} none";
        git_status_other = "${c.base09} none";

        selected_line = "none ${zed.hover} / none ${c.base00}";
        char_match = "${c.base0A} none bold";
        file_error = "${c.base08} none";

        flag_label = "${c.base03} none";
        flag_value = "${c.base0E} none bold";

        input = "${c.base05} ${c.base01} / ${c.base04} ${c.base00}";

        status_error = "${c.base08} ${zed.errorBg}";
        status_job = "${c.base0A} ${zed.warningBg}";
        status_normal = "${c.base05} ${c.base01} / none none";
        status_italic = "${c.base0E} ${c.base01} italic / none none";
        status_bold = "${c.base0D} ${c.base01} bold / none none";
        status_code = "${c.base0C} ${c.base01} / none none";
        status_ellipsis = "${c.base05} ${c.base01} bold / none none";

        purpose_normal = "none none";
        purpose_italic = "${c.base04} none italic";
        purpose_bold = "${c.base04} none bold";
        purpose_ellipsis = "none none";

        scrollbar_track = "${c.base01} none";
        scrollbar_thumb = "${c.base04} none / ${c.base02} none";

        help_paragraph = "none none";
        help_bold = "${c.base09} none bold";
        help_italic = "${c.base0E} none italic";
        help_code = "${c.base0B} ${c.base01}";
        help_headers = "${c.base0D} none bold";
        help_table_border = "${c.base02} none";

        preview_title = "${c.base05} ${c.base01} / ${c.base04} ${c.base00}";
        preview = "${c.base05} ${c.base00} / ${c.base04} ${c.base00}";
        preview_line_number = "${c.base03} ${c.base01} / ${c.base03} none";
        preview_separator = "${c.base02} none";
        preview_match = "none ${c.base02} bold";

        hex_null = "${c.base03} none";
        hex_ascii_graphic = "${c.base05} none";
        hex_ascii_whitespace = "${c.base03} none";
        hex_ascii_other = "${c.base09} none";
        hex_non_ascii = "${c.base08} none";

        staging_area_title = "${c.base05} ${c.base01} / ${c.base04} ${c.base00}";
        mode_command_mark = "${c.base0E} ${zed.surface} bold";

        good_to_bad_0 = c.base0B;
        good_to_bad_1 = c.base0B;
        good_to_bad_2 = c.base0B;
        good_to_bad_3 = c.base0A;
        good_to_bad_4 = c.base0A;
        good_to_bad_5 = c.base0A;
        good_to_bad_6 = c.base09;
        good_to_bad_7 = c.base09;
        good_to_bad_8 = c.base08;
        good_to_bad_9 = c.base08;
      };
    };
  };

  # broot has no config key for starting with the preview panel open, only the
  # :open_preview verb. The `br` alias calls this function too; an explicit
  # --cmd/-c wins.
  programs.fish.functions.broot = ''
    if contains -- --cmd $argv; or contains -- -c $argv
        command broot $argv
    else
        command broot --cmd :open_preview $argv
    end
  '';
}
