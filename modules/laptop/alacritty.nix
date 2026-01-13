{ pkgs, ... }:
{

  programs.alacritty = {

    enable = true;

    settings = {
      general = {
        import = [ ./dracula.toml ];
      };
    };

  };
}
