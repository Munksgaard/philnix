{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.beadwork;
in
{
  options.laptop.beadwork = {
    enable = lib.mkEnableOption "Beadwork CLI";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.beadwork ];

    home-manager.users.munksgaard.emacsConfig = {
      extraPackageBuilders = [
        (
          epkgs:
          epkgs.trivialBuild {
            pname = "beadwork";
            version = "0.1.0-unstable-2026-05-13";
            src = pkgs.fetchgit {
              url = "https://tangled.org/munksgaard.tngl.sh/beadwork.el";
              rev = "5229266f705086f9fb62ee6c9e37d98af93cf159";
              hash = "sha256-py2ys207NHFVuJaxIrXsdAjqp8jGf3RlITT2RFtwR7M=";
            };
            packageRequires = with epkgs; [
              magit-section
              transient
            ];
          }
        )
      ];

      extraConfig = ''
        (use-package beadwork
          :ensure nil
          :commands (beadwork beadwork-list beadwork-create beadwork-show))
      '';
    };
  };
}
