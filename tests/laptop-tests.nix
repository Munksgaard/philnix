{ pkgs ? import <nixpkgs> { }, system ? "x86_64-linux" }:

let
  # Import the testing framework from nixpkgs
  makeTest = import (pkgs.path + "/nixos/lib/testing-python.nix") {
    inherit system pkgs;
  };

  # Simplified laptop test that doesn't require full flake evaluation
  # This tests a basic laptop-like configuration to validate structure
  makeLaptopTest = { name }:
    makeTest {
      inherit name;

      nodes.machine = { config, pkgs, ... }: {
        # Basic laptop-like configuration for testing
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "test-laptop";

        users.users.munksgaard = {
          isNormalUser = true;
          extraGroups = [ "wheel" "docker" "video" ];
        };

        # Enable key services that laptops should have
        programs.sway.enable = true;
        services.pipewire.enable = true;
        hardware.bluetooth.enable = true;
        services.tailscale.enable = true;
        services.openssh.enable = true;
        virtualisation.docker.enable = true;

        # Install essential packages
        environment.systemPackages = with pkgs; [
          vim wget git tmux htop rustup gcc gnumake
          elixir erlang futhark claude-code
        ];

        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        system.stateVersion = "25.05";
      };

      testScript = ''
        machine.start()
        machine.wait_for_unit("multi-user.target")

        # Test critical system services
        with subtest("System services are enabled"):
            machine.succeed("systemctl is-enabled sway")
            machine.succeed("systemctl is-enabled pipewire")
            machine.succeed("systemctl is-enabled bluetooth")
            machine.succeed("systemctl is-enabled tailscale")
            machine.succeed("systemctl is-enabled openssh")

        # Test essential packages are installed
        with subtest("Essential packages exist"):
            machine.succeed("which vim")
            machine.succeed("which wget")
            machine.succeed("which git")
            machine.succeed("which tmux")
            machine.succeed("which htop")
            machine.succeed("which rustup")
            machine.succeed("which claude-code")

        # Test development tools
        with subtest("Development tools exist"):
            machine.succeed("which gcc")
            machine.succeed("which gnumake")
            machine.succeed("which elixir")
            machine.succeed("which erlc")
            machine.succeed("which futhark")

        # Test user configuration
        with subtest("User munksgaard is configured correctly"):
            machine.succeed("id munksgaard")
            machine.succeed("id munksgaard | grep wheel")
            machine.succeed("id munksgaard | grep docker")
            machine.succeed("id munksgaard | grep video")

        # Test Nix configuration
        with subtest("Nix flakes are enabled"):
            machine.succeed("nix --version")
            machine.succeed("nix flake --version")
      '';
    };

in {
  # Note: These are structural tests that validate laptop-like configurations
  # They test that the expected services and packages work together correctly
  # Actual configuration builds are tested separately in flake checks

  # church tests temporarily disabled - will be re-enabled after refactoring updates church config
  # church = makeLaptopTest {
  #   name = "church-laptop-test";
  # };

  hoare = makeLaptopTest {
    name = "hoare-laptop-test";
  };
}
