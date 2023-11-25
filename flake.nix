{
  description = "Deployment for my server cluster";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.geomyidae = {
    url = "sourcehut:~munksgaard/geomyidae-flake";
  };

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
  };

  inputs.digit = {
    url = "sourcehut:~munksgaard/digit";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, geomyidae, agenix, munksgaard-gopher, photos, digit }@attrs:
    let system = "x86_64-linux";
        # Unmodified nixpkgs
        pkgs = import nixpkgs { inherit system; };
        # nixpkgs with deploy-rs overlay but force the nixpkgs package
        deployPkgs = import nixpkgs {
          inherit system;
          overlays = [
            deploy-rs.overlay
            (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
          ];
        };
    in {

    devShells."x86_64-linux".default =
      pkgs.mkShell {
        buildInputs = [ pkgs.deploy-rs ];
      };

    nixosConfigurations."munksgaard.me" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        server/server.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations."photos.munksgaard.me" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        photos/photos.nix
        agenix.nixosModules.default
        photos.nixosModules.photos
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
      hostname = "202:1519:efec:5cbb:b1b5:f995:920e:31a9";

      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos
          self.nixosConfigurations."photos.munksgaard.me";
        magicRollback = false;
      };
    };

    nixosConfigurations.church = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        church/church.nix
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
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
