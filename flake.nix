{
  description = "Deployment for my server cluster";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.geomyidae.url = "sourcehut:~munksgaard/geomyidae-flake";
  inputs.munksgaard-gopher.url = "sourcehut:~munksgaard/munksgaard.me-gopher";

  inputs.agenix.url = "github:ryantm/agenix";

  outputs = { self, nixpkgs, deploy-rs, geomyidae, agenix, munksgaard-gopher }@attrs: {

    nixosConfigurations."munksgaard.me" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        server/server.nix
        agenix.nixosModule
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

    # nixosConfigurations.church = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     church/church.nix
    #   ];
    # };

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
