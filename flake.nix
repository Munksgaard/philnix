{
  description = "Deployment for my server cluster";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.geomyidae = { url = "sourcehut:~munksgaard/geomyidae-flake"; };

  inputs.munksgaard-gopher = {
    url = "sourcehut:~munksgaard/munksgaard.me-gopher";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.photos = {
    url = "sourcehut:~munksgaard/photo-album";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  inputs.flake-parts = { url = "github:hercules-ci/flake-parts"; };

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nur.url = "github:nix-community/NUR";

  inputs.sorgenfri.url = "sourcehut:~munksgaard/sorgenfri";

  inputs.emacs-overlay = {
    url = "github:nix-community/emacs-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = inputs@{ flake-parts, self, nixpkgs, deploy-rs, geomyidae, agenix
    , munksgaard-gopher, photos, home-manager, sorgenfri, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlay
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };

    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ system ];
      flake =
        # nixpkgs with deploy-rs overlay but force the nixpkgs package
        {

          devShells."${system}".default =
            pkgs.mkShell { buildInputs = [ pkgs.deploy-rs pkgs.just pkgs.gh ]; };

          nixosConfigurations."munksgaard.me" = nixpkgs.lib.nixosSystem {
            system = "${system}";
            specialArgs = inputs;
            modules = [ server/server.nix agenix.nixosModules.default ];
          };

          nixosConfigurations."photos.munksgaard.me" = nixpkgs.lib.nixosSystem {
            system = "${system}";
            specialArgs = inputs // {
              sorgenfri = sorgenfri.packages."x86_64-linux".sorgenfri;
            };
            modules = [
              sorgenfri-test/sorgenfri.nix
              agenix.nixosModules.default
              sorgenfri.nixosModules.sorgenfri
            ];
          };

          deploy.nodes."munksgaard.me" = {
            hostname = "munksgaard.me";

            profiles.system = {
              sshUser = "root";
              user = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations."munksgaard.me";
            };
          };

          deploy.nodes."photos.munksgaard.me" = {
            hostname = "photos.munksgaard.me";

            profiles.system = {
              sshUser = "root";
              user = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations."photos.munksgaard.me";
              magicRollback = false;
            };
          };

          nixosConfigurations.church = nixpkgs.lib.nixosSystem {
            system = "${system}";
            specialArgs = inputs;
            modules = [
              {
                nixpkgs.overlays =
                  [ inputs.nur.overlay (import self.inputs.emacs-overlay) ];
              }
              church/church.nix
              home-manager.nixosModules.default
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.munksgaard.imports = [ ./church/home.nix ];
              }
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x390
            ];
          };

          nixosConfigurations.hoare = nixpkgs.lib.nixosSystem {
            system = "${system}";
            specialArgs = inputs;
            modules = [
              {
                nixpkgs.overlays =
                  [ inputs.nur.overlay (import self.inputs.emacs-overlay) ];
              }
              hoare/hoare.nix
              home-manager.nixosModules.default
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.munksgaard.imports = [ ./hoare/home.nix ];
              }
              inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
            ];
          };

          # No deploy for localhost, use `sudo nixos-rebuild switch --flake .#church` instead
          # deploy.nodes.church = {
          #   hostname = "localhost";

          #   profiles.system = {
          #     sshUser = "munksgaard";
          #     user = "root";
          #     path = deploy-rs.lib.x86_64-linux.activate.nixos
          #       self.nixosConfigurations.church;
          #   };
          # };

          # This is highly advised, and will prevent many possible mistakes
          checks = builtins.mapAttrs
            (system: deployLib: deployLib.deployChecks self.deploy)
            deploy-rs.lib;
        };
    };
}
