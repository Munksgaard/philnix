{ pkgs, ... }: {
  home.packages = [ pkgs.atool pkgs.httpie ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs = {
    bash.enable = true;

    starship = {
      enable = true;
      settings = {
        time.disabled = false;
        status.disabled = false;
      };
    };
  };
}
