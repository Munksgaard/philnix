{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.codex;
  agentGit = import ./lib/agent-git.nix { inherit lib pkgs; };
in
{
  options.laptop.codex = {
    enable = lib.mkEnableOption "Codex integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (agentGit.wrapMainProgramWithUnsignedGit pkgs.codex)
      (agentGit.wrapMainProgramWithUnsignedGit pkgs.codex-acp)
    ];
  };
}
