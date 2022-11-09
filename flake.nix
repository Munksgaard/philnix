{
  description = "Deployment for my server cluster";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.geomyidae.url = "sourcehut:~munksgaard/geomyidae-flake";
  inputs.munksgaard-gopher.url = "sourcehut:~munksgaard/munksgaard.me-gopher";
  inputs.photos.url = "sourcehut:~munksgaard/photo-album";

  inputs.agenix.url = "github:ryantm/agenix";

  outputs = { self, nixpkgs, deploy-rs, geomyidae, agenix, munksgaard-gopher, photos }@attrs: {

    nixosConfigurations."munksgaard.me" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        server/server.nix
        agenix.nixosModule
      ];
    };

    nixosConfigurations."photos.munksgaard.me" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        photos/photos.nix
        agenix.nixosModule
        photos.nixosModules.photos
      ];
    };

    deploy.nodes."munksgaard.me" = {
      hostname = "munksgaard.me";

      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations."munksgaard.me";
      };
    };

    deploy.nodes."photos.munksgaard.me" = {
      hostname = "202:1519:efec:5cbb:b1b5:f995:920e:31a9";

      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations."photos.munksgaard.me";
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


    checks =
      builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;
  };
}
