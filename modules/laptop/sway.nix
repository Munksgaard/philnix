{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.sway;

  # Preserve i3status's JSON blocks and colours while adding Linux swap usage.
  swapStatus = pkgs.writeText "swaybar-swap.py" ''
    import json
    import sys

    def swap_block():
        with open("/proc/meminfo") as meminfo:
            values = {
                fields[0].rstrip(":"): int(fields[1])
                for line in meminfo
                if (fields := line.split())
            }
        total = values["SwapTotal"]
        used = total - values["SwapFree"]
        text = (
            f"SWAP {used / 1024**2:.1f}/{total / 1024**2:.1f} GiB"
            if total else "SWAP off"
        )
        return {"name": "swap", "full_text": text}

    for line in sys.stdin:
        prefix = "," if line.lstrip().startswith(",") else ""
        payload = line.lstrip().removeprefix(",")
        try:
            blocks = json.loads(payload)
        except json.JSONDecodeError:
            # The opening bracket of the streaming array is on its own line.
            print(line, end="", flush=True)
            continue
        if not isinstance(blocks, list):
            # Pass through the i3bar protocol header unchanged.
            print(line, end="", flush=True)
            continue
        position = next(
            (i + 1 for i, block in enumerate(blocks) if block.get("name") == "memory"),
            len(blocks),
        )
        blocks.insert(position, swap_block())
        print(prefix + json.dumps(blocks), flush=True)
  '';
in
{
  options.laptop.sway = {
    enable = lib.mkEnableOption "Sway window manager";
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;
    programs.sway.enable = true;

    home-manager.users.munksgaard.programs.i3status = {
      enable = true;
      # Explicitly use JSON even when i3status writes into the swap filter pipe.
      general.output_format = "i3bar";
    };

    home-manager.users.munksgaard.wayland.windowManager.sway = {
      enable = true;
      checkConfig = true;
      config = rec {
        modifier = "Mod4";
        terminal = "${pkgs.ghostty}/bin/ghostty";
        left = "h";
        down = "j";
        up = "k";
        right = "l";
        menu = "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu | ${pkgs.findutils}/bin/xargs swaymsg exec --";

        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_variant = "altgr-intl";
            xkb_options = "ctrl:nocaps";
          };
          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
          };
        };

        focus.mouseWarping = false;

        floating = {
          criteria = [
            { title = "Steam - Update News"; }
            { app_id = "org.pulseaudio.pavucontrol"; }
          ];
        };

        bars = [
          {
            position = "top";

            statusCommand = "${pkgs.i3status}/bin/i3status | ${pkgs.python3}/bin/python3 ${swapStatus}";

            colors = {
              statusline = "#ffffff";
              background = "#323232";
              inactiveWorkspace = {
                border = "#32323200";
                background = "#32323200";
                text = "#5c5c5c";
              };
            };
          }
        ];

        bindswitches =
          let
            laptop = "eDP-1";
          in
          {
            "lid:on" = {
              reload = true;
              locked = true;
              action = "output ${laptop} disable";
            };
            "lid:off" = {
              reload = true;
              locked = true;
              action = "output ${laptop} enable";
            };
          };

        keybindings = lib.mkOptionDefault {
          # Start a terminal
          "${modifier}+Return" = "exec ${terminal}";

          # Kill focused window
          "${modifier}+Shift+c" = "kill";

          # Start your launcher
          "${modifier}+p" = "exec ${menu}";

          # Reload the configuration file
          "${modifier}+q" = "reload";

          # Exit sway (logs you out of your Wayland session)
          "${modifier}+Shift+q" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
          #
          # Moving around:
          #
          # Move your focus around
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";
          # Or use ${modifier}+[up|down|left|right]
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # # Move the focused window with the same, but add Shift
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";
          # Ditto, with arrow keys
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";

          "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 5%-";
          "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle";

          "Print" = ''
            exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
              | tee ~/tmp/screenshot.png \
              | ${pkgs.wl-clipboard}/bin/wl-copy
          '';

          #
          # Workspaces:
          #
          # Switch to workspace
          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          # Move focused container to workspace
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
          # Note: workspaces can have any name you want, not just numbers.
          # We just use 1-10 as the default.
          #
          # Layout stuff:
          #
          # You can "split" the current object of your focus with
          # ${modifier}+b or ${modifier}+v, for horizontal and vertical splits
          # respectively.
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";

          # Switch the current container between different layout styles
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";

          # Make the current focus fullscreen
          "${modifier}+f" = "fullscreen";

          # Toggle the current focus between tiling and floating mode
          "${modifier}+Shift+space" = "floating toggle";

          # Swap focus between the tiling area and the floating area
          "${modifier}+space" = "focus mode_toggle";

          # Move focus to the parent container
          "${modifier}+a" = "focus parent";
          #
          # Scratchpad:
          #
          # Sway has a "scratchpad", which is a bag of holding for windows.
          # You can send windows there and get them back later.

          # Move the currently focused window to the scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          "${modifier}+minus" = "scratchpad show";
          "${modifier}+equal" = "scratchpad show";

          # Move the currently focused window to the scratchpad
          "${modifier}+Shift+backspace" = "move scratchpad";

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          "${modifier}+backspace" = "scratchpad show";
          # pavucontrol
          "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

          # swaylock
          "${modifier}+Shift+o" = "exec ${pkgs.swaylock}/bin/swaylock";

          # emacs
          "${modifier}+Shift+e" = "exec emacsclient -c";

          # emacs
          "${modifier}+Shift+f" = "exec firefox";

        };

      };

      systemd.xdgAutostart = true;

    };
  };
}
