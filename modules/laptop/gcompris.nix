{ config, lib, ... }:

{
  imports = [ ../gcompris.nix ];

  options.laptop.gcompris.enable = lib.mkEnableOption "GCompris educational software suite";

  config.programs.gcompris.enable = lib.mkIf config.laptop.gcompris.enable true;
}
