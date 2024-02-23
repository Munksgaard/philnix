{ pkgs, ... }: {

  programs.alacritty = {

    enable = true;

    settings = {
      import = [./dracula.toml];
    };

  };
}
