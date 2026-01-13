# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  sorgenfri,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/server
  ];

  # Enable server module
  server.enable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking = {
    hostName = "photos";
    domain = "photos.munksgaard.me";
  };

  # Override locale from common (this server uses Danish locale)
  i18n.defaultLocale = "en_DK.UTF-8";

  # Additional packages (base utils are in common module)
  environment.systemPackages = with pkgs; [
    sorgenfri
    sqlite
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  age.secrets.photos-secret-key-base.file = ../secrets/photos-secret-key-base.age;

  age.secrets.photos-smtp-password.file = ../secrets/photos-smtp-password.age;

  age.secrets.sorgenfri-s3-access-key.file = ../secrets/sorgenfri-s3-access-key.age;
  age.secrets.sorgenfri-s3-secret-access-key.file = ../secrets/sorgenfri-s3-secret-access-key.age;

  services.sorgenfri = {
    enable = true;
    address = "photos.munksgaard.me";
    port = 8000;
    secretKeyBaseFile = config.age.secrets.photos-secret-key-base.path;
    releaseCookie = "my_cookie";
    releaseDistribution = "sname";
    smtp = {
      username = "philip@munksgaard.me";
      passwordFile = config.age.secrets.photos-smtp-password.path;
      host = "smtp.fastmail.com";
    };

    s3 = {
      host = "fra1.digitaloceanspaces.com";
      region = "fra1";
      accessKeyFile = config.age.secrets.sorgenfri-s3-access-key.path;
      secretAccessKeyFile = config.age.secrets.sorgenfri-s3-secret-access-key.path;
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."photos.munksgaard.me".extraConfig = ''
      reverse_proxy http://localhost:4000
    '';
  };

  services.cloud-init.enable = true;
}
