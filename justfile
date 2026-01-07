# List available recipes
help:
    @just --list

# Deploy everything
deploy:
    nix develop -c deploy '.'

# Deploy munksgaard.me
deploy-munksgaard.me:
    nix develop -c deploy '.#"munksgaard.me".'

# Deploy photos.munksgaard.me
deploy-photos.munksgaard.me:
    nix develop -c deploy '.#"photos.munksgaard.me".'

# Deploy sorgenfri.munksgaard.me
deploy-sorgenfri.munksgaard.me:
    nix develop -c deploy '.#"sorgenfri.munksgaard.me".'

# Deploy church (local nixos-rebuild)
deploy-church:
    sudo nixos-rebuild switch --flake .#church

# Deploy hoare (local nixos-rebuild)
deploy-hoare:
    sudo nixos-rebuild switch --flake .#hoare

# Update munksgaard.me-gopher flake input
update-munksgaard.me-gopher:
    nix flake update munksgaard-gopher

# Update photos flake input
update-photos:
    nix flake update photos

# Update nixpkgs flake input
update-nixpkgs:
    nix flake update nixpkgs

# Update sorgenfri flake input
update-sorgenfri:
    nix flake update sorgenfri

# Update home-manager flake input
update-home-manager:
    nix flake update home-manager
