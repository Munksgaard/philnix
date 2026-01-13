{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.common;
in
{
  options.common = {
    enable = mkEnableOption "common configuration shared by all devices";

    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu"
      ];
      description = "SSH authorized keys";
    };

    enableGC = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic nix garbage collection";
    };
  };

  config = mkIf cfg.enable {
    # Nix settings
    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    # Garbage collection
    nix.gc = mkIf cfg.enableGC {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };

    # Timezone and locale (use mkDefault so they can be overridden)
    time.timeZone = lib.mkDefault "Europe/Copenhagen";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    # Console settings
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # Enable SSH
    services.openssh.enable = true;

    # Universal packages
    environment.systemPackages = with pkgs; [
      git
      vim
      tmux
      htop
      wget
      curl
      ripgrep
      fd
    ];
  };
}
