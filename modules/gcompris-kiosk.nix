{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gcompris-kiosk;
  gcompris = config.programs.gcompris;
in
{
  imports = [ ./gcompris.nix ];

  options.services.gcompris-kiosk = {
    enable = lib.mkEnableOption "Danish GCompris kiosk";
    kioskMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hide GCompris configuration and quit buttons. Disable temporarily for setup.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gcompris.enable = true;

    users.users.gcompris = {
      isNormalUser = true;
      description = "GCompris kiosk";
      home = "/home/gcompris";
      createHome = true;
      hashedPassword = "!";
    };

    services.cage = {
      enable = true;
      user = "gcompris";
      restartIfChanged = true;
      # Keep Ctrl+Alt+F2 available for maintenance.
      extraArguments = [ "-s" ];
      environment = {
        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_PLUGIN_PATH = "${pkgs.kdePackages.qtwayland}/${pkgs.kdePackages.qtbase.qtPluginPrefix}";
        XKB_DEFAULT_LAYOUT = "dk";
      };
      program = pkgs.writeShellScript "start-gcompris" ''
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        exec ${lib.getExe gcompris.package} \
          --fullscreen \
          --${if cfg.kioskMode then "enable" else "disable"}-kioskmode \
          --locale da_DK
      '';
    };

    systemd.services.cage-tty1 = {
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
        WorkingDirectory = "/home/gcompris";
      };
    };

    # Prepare voices before Cage starts, without racing the PAM-created user
    # manager's tmpfiles service. Keep the parent directories user-writable.
    systemd.tmpfiles.rules = [
      "d /home/gcompris/.local 0755 gcompris users -"
      "d /home/gcompris/.local/share 0755 gcompris users -"
      "d /home/gcompris/.local/share/GCompris 0755 gcompris users -"
      "d /home/gcompris/.local/share/GCompris/voices-ogg 0755 gcompris users -"
      "L+ /home/gcompris/.local/share/GCompris/voices-ogg/da - - - - ${gcompris.danishVoices}/da"
    ];

    services.dbus.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    fonts.packages = [ pkgs.dejavu_fonts ];
  };
}
