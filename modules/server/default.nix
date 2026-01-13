{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.server;
  commonCfg = config.common;
in {
  imports = [ ../common ];

  options.server = {
    enable = mkEnableOption "server-specific configuration";

    enableFail2ban = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fail2ban service";
    };

    hardenSSH = mkOption {
      type = types.bool;
      default = true;
      description = "Apply SSH hardening settings";
    };

    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ 22 80 443 ];
      description = "Allowed TCP ports in firewall";
    };
  };

  config = mkIf cfg.enable {
    common.enable = true;

    services.fail2ban.enable = cfg.enableFail2ban;

    services.openssh.settings = mkIf cfg.hardenSSH {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };

    users.users.root.openssh.authorizedKeys.keys = commonCfg.authorizedKeys;

    networking.firewall.allowedTCPPorts = cfg.allowedTCPPorts;

    services.journald.extraConfig = "SystemMaxUse=1G";
  };
}
