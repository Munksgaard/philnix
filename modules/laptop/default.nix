{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.laptop;

in
{
  imports = [
    ./wl-mirror.nix
    ./printing.nix
    ./calibre.nix
    ./claude-code.nix
    ./elixir.nix
    ./ergodox.nix
    ./futhark.nix
    ./gcompris.nix
    ./livebook.nix
    ./ghostty.nix
    ./rust.nix
    ./steam.nix
    ./sml.nix
    ./sway.nix
    ./tmux.nix
    ../common
  ];

  options.laptop = {
    redshift.enable = mkEnableOption "Gammastep/redshift for blue light filtering";
    intelGpu.enable = mkEnableOption "Intel GPU packages (VAAPI, OpenCL)";
  };

  config = {
    # Enable common module (but disable GC for laptops)
    common.enable = true;
    common.enableGC = false;

    # Allow unfree modules
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken = true;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      hack-font
      font-awesome
    ];

    programs.gnupg.agent = { enable = true; };

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers =
      [ pkgs.gutenprint pkgs.gutenprintBin pkgs.canon-cups-ufr2 ];

    services.pulseaudio.enable = false;
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # https://github.com/NixOS/nixos-hardware/issues/1603
      wireplumber.extraConfig.no-ucm = {
        "monitor.alsa.properties" = { "alsa.use-ucm" = false; };
      };
    };

    # Bluetooth
    hardware.bluetooth.enable = true;

    # Enable upower
    services.upower.enable = true;

    # Add docker virtualization
    virtualisation.docker.enable = true;

    # Define a user account. Don't forget to set a password with 'passwd'.
    users.users.munksgaard = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable 'sudo' for the user.
        "video" # Support for using the video device
        "docker" # Can run docker images
        "networkmanager" # can control network manager
        "adbusers" # Can run adb
      ];
    };

    environment = { extraOutputsToInstall = [ "dev" ]; };

    programs.ssh.startAgent = true;

    # List packages installed in system profile.
    # Additional packages (base utils like git, vim, htop, wget, curl, ripgrep, fd are in common)
    environment.systemPackages = with pkgs;
      [
        dmenu
        xdg-utils

        hicolor-icon-theme
        adwaita-icon-theme

        gnupg
        pinentry-gnome3
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
        killall
        mpv

        spotify

        gnumake
        sbcl

        bc

        sshfs
        sshpass

        ffmpeg

        transmission_4-gtk

        brightnessctl

        # nix stuff
        nixfmt

        discord
        element-desktop
        signal-desktop

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

        # For guix stuff
        guile

        # Bitwarden
        bitwarden-cli

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

        pi-coding-agent
        jujutsu
      ];

    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    programs.dconf.enable = true;

    services.tailscale.enable = true;

    # Redshift/gammastep configuration (optional)
    services.redshift = mkIf cfg.redshift.enable {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };

    location.provider = mkIf cfg.redshift.enable "geoclue2";

    # Intel GPU overlay (optional)
    nixpkgs.config.packageOverrides = mkIf cfg.intelGpu.enable (pkgs: {
      vaapiIntel = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    });

    hardware.graphics = mkIf cfg.intelGpu.enable {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        intel-media-driver
        intel-ocl
        intel-compute-runtime
        ocl-icd
      ];
      enable32Bit = true;
    };

    environment.variables = mkIf cfg.intelGpu.enable {
      OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
    };
  };
}
