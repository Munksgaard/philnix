{ pkgs ? import <nixpkgs> { }, system ? "x86_64-linux" }:

let
  # Import the testing framework from nixpkgs
  makeTest = import (pkgs.path + "/nixos/lib/testing-python.nix") {
    inherit system pkgs;
  };

  # Helper to create a laptop configuration test
  makeLaptopTest = { name, configuration }:
    makeTest.makeTest {
      inherit name;

      nodes.machine = { ... }: {
        imports = [ configuration ];
      };

      testScript = ''
        machine.start()
        machine.wait_for_unit("multi-user.target")

        # Test critical system services
        with subtest("System services are running"):
            # machine.succeed("systemctl is-enabled sway")
            machine.systemctl("is-active pipewire", "munksgaard")
            machine.succeed("systemctl is-enabled bluetooth")
            # machine.succeed("systemctl is-enabled tailscale")
            # machine.succeed("systemctl is-enabled openssh")

        # Test essential packages are installed
        with subtest("Essential packages exist"):
            machine.succeed("which vim")
            machine.succeed("which wget")
            # machine.succeed("which git")
            # machine.succeed("which tmux")
            # machine.succeed("which htop")
            # machine.succeed("which docker")
            # machine.succeed("which rustup")
            # machine.succeed("which claude-code")

        # Test development tools
        with subtest("Development tools exist"):
            machine.succeed("which gcc")
            # machine.succeed("which gnumake")
            # machine.succeed("which rust-analyzer")
            # machine.succeed("which elixir")
            # machine.succeed("which erlc")
            # machine.succeed("which futhark")

        # Test user configuration
        with subtest("User munksgaard is configured correctly"):
            machine.succeed("id munksgaard")
            machine.succeed("id munksgaard | grep wheel")
            machine.succeed("id munksgaard | grep docker")
            machine.succeed("id munksgaard | grep video")

        # Test networking
        with subtest("Hostname is correct"):
            hostname = machine.succeed("hostname").strip()
            assert hostname in ["church", "hoare"], f"Unexpected hostname: {hostname}"

        # Test Nix configuration
        with subtest("Nix flakes are enabled"):
            machine.succeed("nix --version")
            machine.succeed("nix flake --version")
      '';
    };

in {
  # Note: These tests validate that configurations build and basic structure is correct
  # They use dummy hardware-configuration.nix since we're not testing actual hardware

  church = makeLaptopTest {
    name = "church-laptop-test";
    configuration = ../church/church.nix;
  };

  hoare = makeLaptopTest {
    name = "hoare-laptop-test";
    configuration = ../hoare/hoare.nix;
  };
}
