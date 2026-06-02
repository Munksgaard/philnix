{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.claude-code;
in
{
  options.laptop.claude-code = {
    enable = lib.mkEnableOption "Claude Code integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      claude-code
      claude-agent-acp
      libnotify
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package agent-shell
        :ensure t)
    '';
  };
}
