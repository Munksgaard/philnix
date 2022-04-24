let
  nix2105 = import <nix2105> { config = { allowUnfree = true; }; };
  secrets = import ../secrets.nix;

in { config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixUnstable;
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

  programs.gnupg.agent = { enable = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers =
    [ pkgs.gutenprint pkgs.gutenprintBin pkgs.canon-cups-ufr2 ];

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };
  nixpkgs.config.pulseaudio = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
    factorio = pkgs.factorio.override {
      username = "pmunksgaard";
      token = secrets.factorioToken;
    };
  };

  programs.adb.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      nix2105.intel-ocl
      nix2105.intel-compute-runtime
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
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
      # "sway/config".source = ./dotfiles/sway/config;
      # "xdg/waybar/config".source = ./dotfiles/waybar/config;
      # "xdg/waybar/style.css".source = ./dotfiles/waybar/style.css;
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
    alacritty
    bat
    exa
    dmenu
    xdg_utils
    # xdg-desktop-portal-wlr

    hicolor-icon-theme

    firefox-wayland
    chromium

    gitAndTools.gitFull
    gitAndTools.git-annex
    gnupg
    pass-wayland
    pavucontrol
    upower

    zathura
    feh

    unzip
    unrar

    emacs
    aspell

    ripgrep
    fd
    zoxide
    fzf
    hexyl
    bottom

    opencl-headers
    gcc
    glibc
    entr
    file
    htop
    killall
    mpv

    skypeforlinux
    zoom-us

    spotify

    gnumake
    rustup
    sbcl
    killall

    bc

    # haskell stuff
    stack
    ormolu
    hlint

    mosml

    niv
    direnv

    tmux
    sshfs
    sshpass

    ffmpeg
    vlc
    mixxx

    transmission-gtk
    # youtube-dl

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

    # LaTeX and friends
    texlive.combined.scheme-medium
    graphviz
    gnuplot
    python310
    python310Packages.pygments
    python310Packages.pip

    # Accounting
    ledger

    # wally for keyboard config
    wally-cli

    # For guix stuff
    guile

    # Bitwarden
    bitwarden-cli
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

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
    ubuntu_font_family
    hack-font
    vistafonts
    roboto-mono
  ];

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

  # Why is this here?
  services.pipewire.enable = true;

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  programs.dconf.enable = true;

  systemd.services.guix-daemon = {
    enable = true;
    description = "Build daemon for GNU Guix";
    serviceConfig = {
      ExecStart = "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild";
      Environment="GUIX_LOCPATH=/root/.guix-profile/lib/locale";
      RemainAfterExit="yes";
      StandardOutput="syslog";
      StandardError="syslog";
      TaskMax= "8192";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
