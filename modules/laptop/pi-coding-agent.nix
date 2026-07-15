{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.pi-coding-agent;
  agentGit = import ./lib/agent-git.nix { inherit lib pkgs; };
in
{
  options.laptop.pi-coding-agent = {
    enable = lib.mkEnableOption "Pi coding agent integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (agentGit.wrapMainProgramWithUnsignedGit pkgs.pi-coding-agent)
    ];
  };
}
