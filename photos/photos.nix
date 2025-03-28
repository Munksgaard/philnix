# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users =
      [ "root"
        "@wheel"
      ];
  };

  networking = {
    hostName = "photos";
    domain = "photos.munksgaard.me";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.utf8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.munksgaard = {
    isNormalUser = true;
    description = "Philip Munksgaard";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    sudo
    tmux
    htop
    caddy
    yggdrasil
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-22.05";

  services.fail2ban.enable = true;

  services.logind.lidSwitch = "ignore";
  services.upower.ignoreLid = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;

    settings = {
      Peers = [
        "tls://200:9287:bc2e:cf7b:df22:8f0d:d6ce:2715" # church
        "tls://yggdrasil.su:62586" # Why is this needed?
      ];
    };
  };

  age.secrets.photos-secret-key = {
    file = ../secrets/photos-secret-key.age;
    owner = "root";
  };

  age.secrets.photos-smtp-password = {
    file = ../secrets/photos-smtp-password.age;
    owner = "root";
  };

  services.photos = {
    enable = true;
    address = "0.0.0.0";
    port = 8000;
    secretKeyFile = config.age.secrets.photos-secret-key.path;
    smtp = {
      username = "philip@munksgaard.me";
      passwordFile = config.age.secrets.photos-smtp-password.path;
      host = "smtp.fastmail.com";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."photos.munksgaard.me".extraConfig = ''
      reverse_proxy http://localhost:8000
    '';
  };
}
