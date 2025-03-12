{ pkgs, config, ... }: {

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top"; # Waybar at top layer
        position = "top"; # Waybar position (top|bottom|left|right)
        height = 30; # Waybar height (to be removed for auto height)
        # "width": 1280, # Waybar width
        spacing = 4; # Gaps between modules (4px)
        # Choose the order of the modules
        modules-left = [ "niri/workspaces" ];
        modules-center = [ "niri/window" ];
        modules-right = [
          "mpd"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "keyboard-state"
          "sway/language"
          "battery"
          "battery#bat2"
          "clock"
          "tray"
          "custom/power"
        ];
        # Modules configuration
        # "sway/workspaces": {
        #     "disable-scroll": true,
        #     "all-outputs": true,
        #     "warp-on-scroll": false,
        #     "format": "{name}: {icon}",
        #     "format-icons": {
        #         "1": "",
        #         "2": "",
        #         "3": "",
        #         "4": "",
        #         "5": "",
        #         "urgent": "",
        #         "focused": "",
        #         "default": ""
        #     }
        # },
        keyboard-state = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            "locked" = "";
            "unlocked" = "";
          };
        };
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            # Named workspaces
            # (you need to configure them in niri)
            browser = "";
            discord = "";
            chat = "<b></b>";

            # Icons by state
            active = "";
            default = "";
          };
        };
        "niri/window" = {
	        format = "{}";
	        rewrite = {
		        "(.*) - Mozilla Firefox" = "🌎 $1";
		        "(.*) - zsh" = "> [$1]";
          };
	      };
        "sway/mode" = { format = ''<span style="italic">{}</span>''; };
        "sway/scratchpad" = {
          format = "{icon} {count}";
          show-empty = false;
          format-icons = [ "" "" ];
          tooltip = true;
          tooltip-format = "{app}: {title}";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        tray = {
          # "icon-size" = 21,
          spacing = 10;
        };
        clock = {
          # "timezone" = "America/New_York",
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format-alt = "{:%Y-%m-%d}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = { format = "{}% "; };
        temperature = {
          # "thermal-zone" = 2,
          # "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input",
          critical-threshold = 80;
          # "format-critical" = "{temperatureC}°C {icon}",
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };
        backlight = {
          # "device" = "acpi_video1",
          format = "{percent}% {icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };
        battery = {
          states = {
            # "good" = 95,
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          # "format-good" = "", # An empty format will hide the module
          # "format-full" = "",
          format-icons = [ "" "" "" "" "" ];
        };
        "battery#bat2" = { "bat" = "BAT2"; };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = ''
            Power profile: {profile}
            Driver: {driver}'';
          tooltip = true;
          format-icons = {
            "default" = "";
            "performance" = "";
            "balanced" = "";
            "power-saver" = "";
          };
        };
        network = {
          # "interface" = "wlp2*" # (Optional) To force the use of this interface
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          # "scroll-step" = 1, # %, can be a float
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        # "custom/media" = {
        #     format = "{icon} {text}";
        #     return-type = "json";
        #     max-length = 40;
        #     format-icons = {
        #         spotify = "";
        #         default = "🎜";
        #     };
        #     escape = true;
        #     exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null" # Script in resources folder
        #     # "exec" = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
        # },
        "custom/power" = {
          format = "⏻ ";
          tooltip = false;
          #   menu = "on-click";
          # "menu-file" = "$HOME/.config/waybar/power_menu.xml" # Menu file in resources folder
          # "menu-actions" = {
          # 	"shutdown" = "shutdown"
          # 	"reboot" = "reboot"
          # 	"suspend" = "systemctl suspend"
          # 	"hibernate" = "systemctl hibernate"
          # }
        };
      };
    };
  };
}
