{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/laptop
    ./hardware-configuration.nix
  ];

  networking.hostName = "hoare";

  boot.zswap.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # MiB
    }
  ];

  laptop.ergodox.enable = true;
  laptop.steam.enable = true;
  laptop.teams.enable = true;
  laptop.calibre.enable = true;
  laptop.dhall.enable = true;
  laptop.elixir.enable = true;
  laptop.rust.enable = true;
  laptop.futhark.enable = true;
  laptop.beadwork.enable = true;
  laptop.gcompris.enable = true;
  laptop.ghostty.enable = true;
  laptop.git.enable = true;
  laptop.sway.enable = true;
  laptop.tmux.enable = true;
  laptop.claude-code.enable = true;
  laptop.codex.enable = true;
  laptop.pi-coding-agent.enable = true;
  laptop.livebook.enable = true;

  home-manager.users.munksgaard =
    let
      laptop = "eDP-1";
      workMonitor = "Microstep MSI MAG345CQR DD1H255900167";
    in
    {
      # Use the session-level Wayland service, not the legacy laptop.redshift
      # service. Fixed Copenhagen coordinates also work offline, without GeoClue.
      services.gammastep = {
        enable = true;
        provider = "manual";
        latitude = 55.6761;
        longitude = 12.5683;
        temperature = {
          day = 6500;
          night = 3700;
        };
        settings.general.adjustment-method = "wayland";
      };

      services.swayidle = {
        enable = true;
        # Suspend-only locking: no idle locking or display power management.
        timeouts = [ ];
        # Wait until swaylock has acquired the lock before releasing the
        # sleep inhibitor; -f detaches only after the screen is locked.
        extraArgs = [ "-w" ];
        events.before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      };

      services.kanshi.settings = [
        {
          output = {
            criteria = laptop;
            mode = "2880x1920@120Hz";
            scale = 2.0;
            # Leave enable/disable to Sway's lid bindings.
          };
        }
        {
          output = {
            criteria = workMonitor;
            status = "enable";
            mode = "3440x1440@60Hz";
            scale = 1.0;
          };
        }
        {
          profile = {
            name = "work";
            outputs = [
              {
                criteria = laptop;
                # Logical size: 1440x960. Its midpoint is at y=1440,
                # aligned with the bottom of the external monitor.
                position = "0,960";
              }
              {
                criteria = workMonitor;
                position = "1440,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "laptop";
            outputs = [
              {
                criteria = laptop;
                position = "0,0";
              }
            ];
          };
        }
      ];

      wayland.windowManager.sway.config = {
        workspaceOutputAssign = map (number: {
          workspace = toString number;
          output =
            if number == 4 then
              [
                laptop
                workMonitor
              ]
            else
              [
                workMonitor
                laptop
              ];
        }) (lib.range 1 10);

        # Reapply geometry if the dock was connected/disconnected with the lid
        # closed: Kanshi skips mode/position changes on disabled outputs.
        bindswitches."lid:off".action = lib.mkForce (
          "output ${laptop} enable; exec ${pkgs.kanshi}/bin/kanshictl reload"
        );
      };
    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?
}
