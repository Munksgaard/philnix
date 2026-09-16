{
  config,
  lib,
  pkgs,
  gcompris-da,
  gcompris-voices,
  ...
}:

let
  cfg = config.programs.gcompris;
in
{
  options.programs.gcompris = {
    enable = lib.mkEnableOption "GCompris with Danish translations and voices";

    package = lib.mkOption {
      type = lib.types.package;
      default = gcompris-da.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "GCompris package, including the Danish UI and activity translations.";
    };

    danishVoices = lib.mkOption {
      type = lib.types.package;
      # Keep only Danish recordings in the runtime closure.
      default = pkgs.runCommand "gcompris-danish-voices" { } ''
        mkdir -p $out
        cp -r ${gcompris-voices}/da $out/
      '';
      description = "Unpacked Danish recordings, in a da subdirectory.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # GCompris checks unpacked voices before downloadable RCC resources.
    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/GCompris/voices-ogg 0755 - - -"
      "L+ %h/.local/share/GCompris/voices-ogg/da - - - - ${cfg.danishVoices}/da"
    ];
  };
}
