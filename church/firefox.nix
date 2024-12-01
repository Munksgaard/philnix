{ pkgs, ... }: {

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-DK" "da" ];
    package = pkgs.firefox-wayland;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          consent-o-matic
          violentmonkey
          multi-account-containers
        ];
      };
    };

    policies = { DefaultDownloadDirectory = "\${home}/tmp"; };

  };

}
