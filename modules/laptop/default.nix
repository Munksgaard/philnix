{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.laptop;
  beam_pkgs = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
  my_elixir = beam_pkgs.elixir_1_18;
  livebook = pkgs.livebook.override { elixir = my_elixir; };

in {
  imports = [ ./wl-mirror.nix ../common ];

  options.laptop = {
    smlTools.enable = mkEnableOption "SML development tools (mosml, mlton, smlfmt, millet)";
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

    users.groups.plugdev = { };

    # Define a user account. Don't forget to set a password with 'passwd'.
    users.users.munksgaard = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable 'sudo' for the user.
        "video" # Support for using the video device
        "docker" # Can run docker images
        "plugdev" # can run udev rules
        "networkmanager" # can control network manager
        "adbusers" # Can run adb
      ];
    };

    environment = { extraOutputsToInstall = [ "dev" ]; };

    programs.ssh.startAgent = true;

    programs.steam.enable = true;

    # List packages installed in system profile.
    # Additional packages (base utils like git, vim, tmux, htop, wget, curl, ripgrep, fd are in common)
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
        rustup
        rust-analyzer
        cargo-crev
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

        futhark

        claude-code
      ] ++ optionals cfg.smlTools.enable [ mosml mlton smlfmt millet ];

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


    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    programs.dconf.enable = true;

    services.tailscale.enable = true;

    # For sway
    security.polkit.enable = true;
    programs.sway.enable = true;

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
