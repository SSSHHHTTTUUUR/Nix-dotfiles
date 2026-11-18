{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.claude-code;

  # 2.1.314 still advertises ENABLE_LSP_TOOL. The server itself is the official
  # plugin: it runs `rust-analyzer` from PATH for .rs files. Host-specific
  # keys (proxy, hooks, local marketplaces) come in through `settings`.
  lsp = {
    enabledPlugins."rust-analyzer-lsp@claude-plugins-official" = true;
    env.ENABLE_LSP_TOOL = "1";
    extraKnownMarketplaces.claude-plugins-official.source = {
      source = "github";
      repo = "anthropics/claude-plugins-official";
    };
  };

  managed = (pkgs.formats.json { }).generate "claude-settings-managed.json" (
    lib.recursiveUpdate lsp cfg.settings
  );
in
{
  options.dotfiles.claude-code = {
    enable = lib.mkEnableOption ''
      Claude Code user settings for the official rust-analyzer language server
    '';

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Extra ~/.claude/settings.json values, deep-merged under the LSP
        fragment. Proxy, hooks and local marketplace paths belong here.
      '';
    };
  };

  # A store symlink would make the file read-only, and Claude writes model and
  # plugin state into it. Merge instead: keys we do not set survive, including
  # permissions and ANTHROPIC_BASE_URL. A file jq cannot parse is left alone.
  config = lib.mkIf cfg.enable {
    home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      file="$HOME/.claude/settings.json"
      if [ -v DRY_RUN ]; then
        verboseEcho "claude-code: would merge LSP settings into $file"
      else
        mkdir -p "$(dirname "$file")"
        if [ -L "$file" ]; then
          cp --remove-destination "$(readlink -f "$file")" "$file"
          chmod u+w "$file"
        fi
        [ -s "$file" ] || echo '{}' > "$file"
        if merged=$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$file" ${managed}); then
          printf '%s\n' "$merged" > "$file"
        else
          warnEcho "claude-code: $file is not plain JSON; LSP settings not merged"
        fi
      fi
    '';
  };
}
