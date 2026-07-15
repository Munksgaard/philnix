{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.claude-code;
  agentGit = import ./lib/agent-git.nix { inherit lib pkgs; };
in
{
  options.laptop.claude-code = {
    enable = lib.mkEnableOption "Claude Code integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (agentGit.wrapMainProgramWithUnsignedGit pkgs.claude-code)
      pkgs.libnotify
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package agent-shell
        :ensure t)
    '';
  };
}
