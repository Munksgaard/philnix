{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.livebook;
in
{
  options.laptop.livebook = {
    enable = lib.mkEnableOption "Livebook interactive notebook";
  };

  config = lib.mkIf cfg.enable {
    services.livebook = {
      enableUserService = true;
      environment = {
        LIVEBOOK_PORT = 12345;
        LIVEBOOK_TOKEN_ENABLED = false;
      };
      extraPackages = with pkgs; [
        git
        gcc
        gnumake
      ];
    };
  };
}
