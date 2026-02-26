{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.steam;
in
{
  options.laptop.steam = {
    enable = lib.mkEnableOption "Steam and gaming support";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      vulkan-loader
      vulkan-headers
    ];
  };
}
