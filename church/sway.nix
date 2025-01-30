{ pkgs, lib, ... }: {
  # must enable polkit in system configuration
  security.polkit.enable = true;

  home-manager.users.munksgaard.wayland.windowManager.sway = let
    mod = "Mod4";
    left = "h";
    down = "j";
    up = "k";
    right = "l";
    term = "${pkgs.alacritty}/bin/alacritty";
    menu =
      "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu | ${pkgs.findutils}/bin/xargs swaymsg exec --";
  in {
    enable = true;
    config = rec {
      modifier = mod;
      # Use kitty as default terminal
      terminal = term;
      startup = [
        # Launch Firefox on start
        { command = "firefox"; }
      ];
      input = {
        "type:keyboard" = {
          "xkb_layout" = "us";
          "xkb_variant" = "altgr-intl";
          "xkb_options" = "ctrl:nocaps";
        };
        "type:touchpad" = { "events" = "disabled"; };
      };
      # bars = [{
      #   position = "bottom";
      #   colors = {
      #     statusline = "#ffffff";
      #     background = "#323232";
      #     inactiveWorkspace = {
      #       border = "#32323200";
      #       background = "#32323200";
      #       text = "#5c5c5c";
      #     };
      #   };
      #   statusCommand = "${pkgs.i3status}/bin/i3status";
      # }];

      floating.modifier = "${mod} normal";

      focus.mouseWarping = false;

      keybindings = {
        "${mod}+Return" = "exec ${term}";
        "${mod}+Shift+c" = "kill";
        "${mod}+p" = "exec ${menu}";

        # Reload the configuration file
        "${mod}+q" = "reload";

        # Exit sway (logs you out of your Wayland session)
        "${mod}+Shift+q" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        #
        # Moving around:
        #

        # Move your focus around
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";

        # Or use ${mod}+[up|down|left|right]
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # # Move the focused window with the same, but add Shift
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        # Ditto, with arrow keys
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "XF86MonBrightnessDown" =
          "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
        "XF86MonBrightnessUp" =
          "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";

        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_SOURCE@ toggle";

        # todo use pkgs.slurp here
        "Print" = ''
          exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}bin/slurp)" ~/tmp/screenshot.png'';

        #
        # Workspaces:
        #
        # Switch to workspace
        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";
        "${mod}+0" = "workspace 10";
        # Move focused container to workspace
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10";
        # Note: workspaces can have any name you want, not just numbers.
        # We just use 1-10 as the default.
        #
        # Layout stuff:
        #
        # You can "split" the current object of your focus with
        # ${mod}+b or ${mod}+v, for horizontal and vertical splits
        # respectively.
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";

        # Switch the current container between different layout styles
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        # Make the current focus fullscreen
        "${mod}+f" = "fullscreen";

        # Toggle the current focus between tiling and floating mode
        "${mod}+Shift+space" = "floating toggle";

        # Swap focus between the tiling area and the floating area
        "${mod}+space" = "focus mode_toggle";

        # Move focus to the parent container
        "${mod}+a" = "focus parent";
        #
        # Scratchpad:
        #
        # Sway has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.

        # Move the currently focused window to the scratchpad
        "${mod}+Shift+minus" = "move scratchpad";

        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${mod}+minus" = "scratchpad show";
        "${mod}+equal" = "scratchpad show";

        # Move the currently focused window to the scratchpad
        "${mod}+Shift+backspace" = "move scratchpad";

        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${mod}+backspace" = "scratchpad show";
        # pavucontrol
        "${mod}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

        # swaylock
        "${mod}+Shift+o" = "exec ${pkgs.swaylock}/bin/swaylock";

        # emacs
        "${mod}+Shift+e" = "exec emacsclient -c";

        # emacs
        "${mod}+Shift+f" = "exec firefox";

      };

    };
    systemd.enable = true;
  };

}
