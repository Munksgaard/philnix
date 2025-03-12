{ pkgs, config, ... }: {

  programs.niri = {
    enable = true;
    settings = {
      input = {
        focus-follows-mouse.enable = true;
        touchpad.enable = false;
        keyboard.xkb = {
          layout = "us";
          variant = "altgr-intl";
          options = "ctrl:nocaps";
        };
      };
      binds = with config.lib.niri.actions; {
        "Mod+Return".action.spawn = "${pkgs.alacritty}/bin/alacritty";
        "Mod+P".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";
        "Mod+E".action.spawn = "emacsclient -c";
        "Super+Alt+L".action.spawn = "${pkgs.swaylock}/bin/swaylock";

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
        };
        "Mod+Shift+C".action = close-window;

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Ctrl+Left".action = focus-monitor-left;
        "Mod+Ctrl+Down".action = focus-monitor-down;
        "Mod+Ctrl+Up".action = focus-monitor-up;
        "Mod+Ctrl+Right".action = focus-monitor-right;
        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+J".action = focus-monitor-down;
        "Mod+Ctrl+K".action = focus-monitor-up;
        "Mod+Ctrl+L".action = focus-monitor-right;

        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;

        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;

        # You can refer to workspaces by index. However, keep in mind that
        # niri is a dynamic workspace system, so these commands are kind of
        # "best effort". Trying to refer to a workspace index bigger than
        # the current workspace count will instead refer to the bottommost
        # (empty) workspace.

        # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        # will all refer to the 3rd workspace.
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+Ctrl+1".action = move-column-to-workspace 1;
        "Mod+Ctrl+2".action = move-column-to-workspace 2;
        "Mod+Ctrl+3".action = move-column-to-workspace 3;
        "Mod+Ctrl+4".action = move-column-to-workspace 4;
        "Mod+Ctrl+5".action = move-column-to-workspace 5;
        "Mod+Ctrl+6".action = move-column-to-workspace 6;
        "Mod+Ctrl+7".action = move-column-to-workspace 7;
        "Mod+Ctrl+8".action = move-column-to-workspace 8;
        "Mod+Ctrl+9".action = move-column-to-workspace 9;

        # The following binds move the focused window in and out of a column.
        # If the window is alone, they will consume it into the nearby column to the side.
        # If the window is already in a column, they will expel it out.
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        # Consume one window from the right to the bottom of the focused column.
        "Mod+Comma".action = consume-window-into-column;
        # Expel the bottom window from the focused column to the right.
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        # Expand the focused column to space not taken up by other fully visible columns.
        # Makes the column "fill the rest of the space".
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        "Mod+C".action = center-column;

        # Finer width adjustments.
        # This command can also:
        # * set width in pixels: "1000"
        # * adjust width in pixels: "-5" or "+5"
        # * set width as a percentage of screen width: "25%"
        # * adjust width as a percentage of screen width: "-10%" or "+10%"
        # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # set-column-width "100" will make the column occupy 200 physical screen pixels.
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        # Finer height adjustments when in column with other windows.
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # Move the focused window between the floating and the tiling layout.
        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        # Toggle tabbed column display mode.
        # Windows in this column will appear as vertical tabs,
        # rather than stacked on top of each other.
        "Mod+W".action = toggle-column-tabbed-display;

        "Print".action = screenshot;
        # "Ctrl+Print".action = screenshot-screen;
        # "Alt+Print".action = screenshot-window;

        # The quit action will show a confirmation dialog to avoid accidental exits.
        "Mod+Shift+Q".action = quit;

        # Powers off the monitors. To turn them back on, do any input like
        # moving the mouse or pressing any other key.
        "Mod+Shift+P".action = power-off-monitors;

      };
    };
  };
}
