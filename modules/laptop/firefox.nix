{ pkgs, ... }:
{

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    languagePacks = [
      "en-DK"
      "da"
    ];
    package = pkgs.firefox;
  };

}
