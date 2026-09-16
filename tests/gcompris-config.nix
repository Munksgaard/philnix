{
  inputs,
  pkgs,
  configurations,
}:

let
  inherit (pkgs) lib;
  live = configurations.meier-installer.config;
  pending = configurations.meier.config;
  laptop = configurations.hoare.config;

  # Test the installed profile without pretending to know meier's hardware.
  installed =
    (configurations.meier.extendModules {
      modules = [
        {
          disabledModules = [ ../meier/hardware-configuration.nix ];
          fileSystems."/" = {
            device = "/dev/disk/by-label/test-only";
            fsType = "ext4";
          };
          boot.loader.grub.devices = [ "nodev" ];
        }
      ];
    }).config;

  disabled =
    (inputs.nixpkgs.lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      specialArgs = inputs;
      modules = [ ../modules/gcompris-kiosk.nix ];
    }).config;

  danishPackage = inputs.gcompris-da.packages.${pkgs.stdenv.hostPlatform.system}.default;
  valid = cfg: lib.all (a: a.assertion) cfg.assertions;
  usesDanishPackage = cfg: toString cfg.programs.gcompris.package == toString danishPackage;
  hasVoices = cfg: lib.any (rule: lib.hasInfix "voices-ogg/da" rule) cfg.systemd.user.tmpfiles.rules;
in
assert lib.assertMsg (valid live) "The meier ISO must pass NixOS assertions";
assert lib.assertMsg (valid installed)
  "The installed meier profile must pass assertions with test hardware";
assert lib.assertMsg (
  valid pending
  || lib.any (
    a: !a.assertion && lib.hasPrefix "meier: replace meier/hardware-configuration.nix" a.message
  ) pending.assertions
) "Installation must be valid or explicitly blocked by the hardware placeholder";
assert !disabled.programs.gcompris.enable;
assert !disabled.services.cage.enable;
assert laptop.laptop.gcompris.enable && laptop.programs.gcompris.enable;
assert !laptop.services.cage.enable;
assert lib.all usesDanishPackage [
  live
  installed
  laptop
];
assert lib.all hasVoices [
  live
  installed
  laptop
];
assert live.networking.hostName == "meier-installer";
assert installed.networking.hostName == "meier";
assert !live.system.autoUpgrade.enable && !live.nix.gc.automatic;
assert installed.system.autoUpgrade.enable;
assert installed.system.autoUpgrade.flake == "github:Munksgaard/philnix/master#meier";
assert installed.system.autoUpgrade.operation == "boot";
assert !installed.system.autoUpgrade.upgrade && !installed.system.autoUpgrade.allowReboot;
assert installed.system.autoUpgrade.persistent;
assert lib.all
  (
    cfg:
    cfg.services.cage.enable
    && cfg.services.cage.user == "gcompris"
    && cfg.services.cage.restartIfChanged
    && builtins.elem "-s" cfg.services.cage.extraArguments
    && cfg.services.cage.environment.XKB_DEFAULT_LAYOUT == "dk"
    && cfg.services.cage.environment.QT_QPA_PLATFORM == "wayland"
    && cfg.systemd.services.cage-tty1.serviceConfig.Restart == "always"
    && cfg.users.users.gcompris.hashedPassword == "!"
    && !(builtins.elem "wheel" cfg.users.users.gcompris.extraGroups)
    && cfg.services.pipewire.enable
    && cfg.services.pipewire.pulse.enable
    && !cfg.services.openssh.settings.PasswordAuthentication
    && !cfg.services.openssh.settings.KbdInteractiveAuthentication
    && cfg.services.openssh.settings.PermitRootLogin == "no"
    && cfg.users.users.munksgaard.openssh.authorizedKeys.keys == cfg.common.authorizedKeys
  )
  [
    live
    installed
  ];
pkgs.runCommand "gcompris-config-tests" { } ''
  touch $out
''
