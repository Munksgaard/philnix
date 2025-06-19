{ pkgs, ... }: {

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-DK" "da" ];
    package = pkgs.firefox-wayland;
  };

}
