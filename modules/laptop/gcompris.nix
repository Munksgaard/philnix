{
  config,
  lib,
  pkgs,
  gcompris-da,
  gcompris-voices,
  ...
}:

let
  cfg = config.laptop.gcompris;
  gcompris = gcompris-da.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Keep only the Danish voices in the system closure. The source repository
  # contains voice packs for every supported language and is much larger.
  danishVoices = pkgs.runCommand "gcompris-danish-voices" { } ''
    mkdir -p $out
    cp -r ${gcompris-voices}/da $out/
  '';
in
{
  options.laptop.gcompris = {
    enable = lib.mkEnableOption "GCompris educational software suite";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ gcompris ];

    # GCompris looks for unpacked voices here before falling back to its
    # downloadable RCC resources. Install the files for every desktop user.
    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/GCompris/voices-ogg 0755 - - -"
      "L+ %h/.local/share/GCompris/voices-ogg/da - - - - ${danishVoices}/da"
    ];
  };
}
