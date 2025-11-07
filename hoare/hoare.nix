{ config, pkgs, lib, ... }:

let
  beam_pkgs = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
  my_elixir = beam_pkgs.elixir_1_18;
  livebook = pkgs.livebook.override { elixir = my_elixir; };

in {
  imports = [ ./hardware-configuration.nix ./wl-mirror.nix ];

  nix = {
    package = pkgs.nixVersions.stable;
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

  networking.hostName = "hoare";

  networking.wireless.enable = true;

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.munksgaard = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "video" # Support for using the video device
      "docker" # Can run docker images
      "plugdev" # can run udev rules
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?

  environment = { extraOutputsToInstall = [ "dev" ]; };

  programs.ssh.startAgent = true;

  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    dmenu
    xdg-utils
    # xdg-desktop-portal-wlr

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

    sshfs
    sshpass

    ffmpeg

    transmission_4-gtk

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
    nixfmt-classic

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
  ];

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
}
