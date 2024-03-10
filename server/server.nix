{ config, pkgs, lib, geomyidae, munksgaard-gopher, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    geomyidae.nixosModule
  ];

  age.secrets.matrix-extra-conf = {
    file = ../secrets/matrix-extra-conf.age;
    owner = "matrix-synapse";
  };
  age.secrets.gitea-mailer-password = {
    file = ../secrets/gitea-mailer-password.age;
    owner = "gitea";
  };
  age.secrets.vaultwarden-environment.file =
    ../secrets/vaultwarden-environment.age;
  age.secrets.foundry-password = {
    file = ../secrets/foundry-password.age;
    owner = "nginx";
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;

  boot.loader.grub.device = "/dev/sda";

  boot.enableContainers = false;

  networking = {
    hostName = "munksgaard-me";
    domain = "munksgaard.me";
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.channel = "https://nixos.org/channels/nixos-21.05";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philip = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu"
    ];
  };

  environment.systemPackages = with pkgs; [ git sudo tmux htop yggdrasil ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    70 # gopher
    79 # finger
    80 # http
    443 # https
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu"
  ];

  security.acme = {
    defaults.email = "philip@munksgaard.me";
    acceptTerms = true;
  };

  # Need a www-data user for our services.
  users.extraUsers."www-data" = {
    uid = 33;
    group = "www-data";
    home = "/srv/www";
    createHome = true;
    useDefaultShell = true;
  };
  users.extraGroups."www-data".gid = 33;

  services.nginx = {
    enable = true;
    # only recommendedProxySettings and recommendedGzipSettings are strictly required,
    # but the rest make sense as well
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "munksgaard.me" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/munksgaard.me";
        default = true;
        serverAliases = [ "www.munksgaard.me" ];
      };

      "bw.munksgaard.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass =
            "http://localhost:8222"; # changed the default rocket port due to some conflict
          proxyWebsockets = true;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://localhost:3012";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://localhost:8222";
          proxyWebsockets = true;
        };
      };

      # Reverse proxy for Matrix client-server and server-server communication
      "matrix.munksgaard.me" = {
        forceSSL = true;
        enableACME = true;

        # forward all Matrix API calls to the synapse Matrix homeserver
        # locations."/_matrix" = {
        locations."/" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
          '';
        };

        locations."= /.well-known/matrix/server".extraConfig = let
          # use 443 instead of the default 8448 port to unite
          # the client-server and server-server port for simplicity
          server = { "m.server" = "matrix.munksgaard.me:443"; };
        in ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';

        locations."= /.well-known/matrix/client".extraConfig = let
          client = {
            "m.homeserver" = { "base_url" = "https://matrix.munksgaard.me"; };
            "m.identity_server" = { "base_url" = "https://vector.im"; };
          };
          # ACAO required to allow element-web on any URL to request this json file
        in ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '${builtins.toJSON client}';
        '';
      };

      "git.munksgaard.me" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:3000";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
        extraConfig = "client_max_body_size 128M;";
      };

      "foundry.munksgaard.me" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:30000";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            auth_basic "Restricted Content";
            auth_basic_user_file "${config.age.secrets.foundry-password.path}";
          '';
        };
      };
    };
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "matrix.munksgaard.me";
      listeners = [{
        port = 8008;
        bind_addresses = [ "::1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = false;
        }];
      }];
      public_baseurl = "https://matrix.munksgaard.me/";
    };
    extraConfigFiles = [ "${config.age.secrets.matrix-extra-conf.path}" ];
  };

  services.gitea = {
    enable = true;
    # We use a cron script instead. This takes up way too much space
    # dump = {
    #   enable = true;
    #   backupDir = "/var/backup/gitea";
    # };
    settings = {
      mailer = {
        ENABLED = true;
        FROM = "gitea@munksgaard.me";
        MAILER_TYPE = "smtp";
        HOST = "smtp.fastmail.com:465";
        IS_TLS_ENABLED = true;
        USER = "philip@munksgaard.me";
      };
      server = {
        DISABLE_SSH = false;
        ROOT_URL = "https://git.munksgaard.me";
        DOMAIN = "git.munksgaard.me";
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
    mailerPasswordFile = "${config.age.secrets.gitea-mailer-password.path}";
  };

  # services.teeworlds = {
  #   enable = true;
  #   motd = "gamers!";
  #   name = "gamers teeworlds";
  #   openPorts = true;
  #   password = "random password";
  #   register = true;
  #   rconPassword = "another password";
  #   extraOptions = [
  #     "sv_max_clients 12"
  #     "sv_gametype ctf"
  #   ];
  # };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
    ensureDatabases = [ "bitwarden" ];
    ensureUsers = [{
      name = "bitwarden";
      ensureDBOwnership = true;
    }];
    settings = {
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
    };
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      domain = "https://bw.munksgaard.me";
      rocketPort = 8222;
      rocketLog = "critical";
      signupsAllowed = false;
      smtpHost = "smtp.fastmail.com";
      smtpFrom = "bitwarden-rs@munksgaard.me";
      smtpFromName = "Bitwarden_RS";
      smtpPort = 465;
      smtpSsl = true;
      smtpExplicitTls = true;
      smtpUsername = "philip@munksgaard.me";
      smtpAuthMechanism = "Plain";
    };
    environmentFile = "${config.age.secrets.vaultwarden-environment.path}";
    backupDir = "/var/backup/bitwarden_rs";
  };

  services.borgbackup.jobs = {
    borgbase_backup = {
      paths = [ "/var/backup" ];
      #exclude = [ "/nix" "'**/.cache'" ];
      repo = "oexbg24h@oexbg24h.repo.borgbase.com:repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /run/keys/borgbackup_passphrase";
      };
      environment.BORG_RSH = "ssh -i /run/keys/id_ed25519_borgbase";
      compression = "auto,lzma";
      startAt = "daily";
      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7;
        weekly = 2;
        monthly = 1; # Keep at least one archive for each month
      };
    };
  };

  services.fail2ban.enable = true;

  systemd = {
    timers.gitea-dump = {
      wantedBy = [ "timers.target" ];
      partOf = [ "gitea-dump.service" ];
      timerConfig.OnCalendar = "daily";
    };
    services.gitea-dump = {
      serviceConfig = {
        Type = "oneshot";
        User = "gitea";
        Group = "gitea";
      };
      script = ''
        #!/bin/sh
                         set -e
                         cd /var/backup/gitea

                         # Remove existing backups
                         rm -f gitea-dump*

                         GITEA_WORK_DIR=/var/lib/gitea gitea dump > /dev/null

                         # Overwrite any earlier file since these dumps take up a bit of space.
                         mv -f gitea-dump-*.zip gitea-dump.zip
      '';
      path = [ pkgs.gitea ];
    };
  };

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

  services.journald.extraConfig = "SystemMaxUse=1G";

  services.geomyidae = {
    enable = true;
    base = "${munksgaard-gopher}/src";
    host = "munksgaard.me";
  };

  services.cloud-init.enable = true;


  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
  };
}
