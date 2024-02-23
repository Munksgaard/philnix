{ config, pkgs, lib, ... }:

let
  beam_pkgs = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
  my_elixir = beam_pkgs.elixir_1_16;
  livebook = pkgs.livebook.override { elixir = my_elixir; };

in {
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Allow unfree modules
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "church";

  networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    hack-font
  ];

  programs.gnupg.agent = { enable = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers =
    [ pkgs.gutenprint pkgs.gutenprintBin pkgs.canon-cups-ufr2 ];

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable upower
  services.upower.enable = true;

  # Add docker virtualization
  virtualisation.docker.enable = true;

  users.groups.plugdev = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.munksgaard = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "video" # Support for using the video device
      "docker" # Can run docker images
      "plugdev" # can run udev rules
      "adbusers" # Can run adb
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  # Stuff to make OpenCL work properly...
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  programs.adb.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      intel-ocl
      intel-compute-runtime
      ocl-icd
    ];
    driSupport32Bit = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      xwayland
      wl-clipboard
      waybar # status bar
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu
      kanshi # autorandr
    ];
  };

  environment = {
    extraOutputsToInstall = [ "dev" ];
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
      # "sway/config".source = ./dotfiles/sway/config;
      # "xdg/waybar/config".source = ./dotfiles/waybar/config;
      # "xdg/waybar/style.css".source = ./dotfiles/waybar/style.css;
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };
  };

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  services.redshift = {
    enable = true;
    package = pkgs.gammastep;
    executable = "/bin/gammastep";
  };

  services.lorri.enable = true;

  location.provider = "geoclue2";

  programs.waybar.enable = true;

  programs.ssh.startAgent = true;

  programs.steam.enable = true;

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    dmenu
    xdg_utils
    # xdg-desktop-portal-wlr

    hicolor-icon-theme
    gnome.adwaita-icon-theme

    gnupg
    pinentry
    pass-wayland
    pavucontrol
    upower

    unzip
    unrar

    # for emacs?
    sqlite

    opencl-headers
    gcc
    glibc
    entr
    file
    htop
    killall
    mpv

    spotify

    gnumake
    rustup
    rust-analyzer
    cargo-crev
    sbcl

    bc

    mosml
    mlton
    smlfmt
    millet

    tmux
    sshfs
    sshpass

    ffmpeg

    transmission-gtk

    brightnessctl

    ## Games

    # dwarf-fortress-packages.dwarf-fortress-full

    # Sea of Thieves override, from here:
    # https://github.com/NixOS/nixpkgs/issues/76516#issuecomment-599663719
    # Also take a look at /home/munksgaard/.steam/steam/steamapps/common/SteamLinuxRuntime_soldier/_v2-entry-point
    # (steam.override { extraPkgs = pkgs: [ cabextract gnutls openldap winetricks ]; })
    # # steam
    # mesa.drivers
    # expat
    # wayland
    # xlibs.libxcb
    # xlibs.libXdamage
    # xlibs.libxshmfence
    # xlibs.libXxf86vm
    # llvm_11.lib
    # libelf

    # nix stuff
    nixfmt

    discord
    element-desktop

    # lutris
    vulkan-loader
    vulkan-headers

    # Screenshots (use `grim -g "$(slurp)" screenshot.png`)
    grim
    slurp

    # dns
    bind
    whois

    zlib
    pkg-config
    inetutils
    openconnect

    # Accounting
    ledger

    # wally for keyboard config
    wally-cli

    # For guix stuff
    guile

    # Bitwarden
    bitwarden-cli

    yggdrasil

    # for `man ascii` and others
    man-pages

    aspell
    aspellDicts.en
    aspellDicts.da

    # racket
    racket

    # notmuch
    notmuch

    libreoffice

    beam_pkgs.erlang
    beam_pkgs.elixir-ls
    my_elixir
  ];

  xdg.mime.enable = true;

  services.udev.packages = [ pkgs.android-udev-rules ];

  # Stuff for the Ergodox Moonlander
  services.udev.extraRules = ''
      # Teensy rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      # STM32 rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
          MODE:="0666", \
          SYMLINK+="stm32_dfu"

     # Rule for the Moonlander
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  '';

  # Let's play with containers and funkwhale
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
  #     funkwhale = {
  #       image = "funkwhale/all-in-one:1.1.1";
  #       ports = ["5000:80"];
  #       volumes = [
  #         "/srv/funkwhale/data:/data"
  #         "/var/music:/music:ro"
  #       ];
  #       environment = {
  #         # Replace 'your.funkwhale.example' with your actual domain
  #         FUNKWHALE_HOSTNAME = "localhost";
  #         # Protocol may also be: http
  #         # FUNKWHALE_PROTOCOL = "https";
  #         FUNKWHALE_PROTOCOL = "http";
  #         # This limits the upload size
  #         NGINX_MAX_BODY_SIZE = "100M";
  #         # Bind to localhost
  #         FUNKWHALE_API_IP = "127.0.0.1";
  #         # Container port you want to expose on the host
  #         FUNKWHALE_API_PORT = "5000";
  #         # Generate and store a secure secret key for your instance
  #         DJANGO_SECRET_KEY = "RANDOM LONG KEY";
  #         # Remove this if you expose the container directly on ports 80/443
  #         NESTED_PROXY = "1";
  #       };
  #     };
  #   };
  # };

  # systemd.services.podman-funkwhale.serviceConfig.User = "funkwhale";
  # systemd.services.podman-funkwhale.wantedBy = [ "default.target" ];

  # From https://github.com/calbrecht/nixpkgs-overlays
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ # pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP =
      "sway"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_TYPE =
      "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };

  environment.variables = {
    OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
  };

  programs.dconf.enable = true;

  systemd.services.guix-daemon = {
    enable = true;
    description = "Build daemon for GNU Guix";
    serviceConfig = {
      ExecStart =
        "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild";
      Environment = "GUIX_LOCPATH=/root/.guix-profile/lib/locale";
      RemainAfterExit = "yes";
      StandardOutput = "syslog";
      StandardError = "syslog";
      TaskMax = "8192";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;

    settings = {
      Peers = [
        "http://[319:3cf0:dd1d:47b9:20c:29ff:fe2c:39be]/"
        "tls://185.130.44.194:7040"
        "http://[319:3cf0:dd1d:47b9:20c:29ff:fe2c:39bd]/"
        "tls://[202:1519:efec:5cbb:b1b5:f995:920e:31a9]" # photos
        "tls://[200:d513:d94c:fa8d:8357:f8c0:9c0e:153e]" # hetzner
      ];
    };
  };

  services.livebook = {
    package = livebook;
    enableUserService = true;
    port = 20123;
    # See note below about security
    environmentFile = pkgs.writeText "livebook.env" ''
      LIVEBOOK_PASSWORD = "password1234"
    '';
  };
}
