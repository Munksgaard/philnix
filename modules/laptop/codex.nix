{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.codex;
in
{
  options.laptop.codex = {
    enable = lib.mkEnableOption "Codex integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      codex
      codex-acp
    ];
  };
}
