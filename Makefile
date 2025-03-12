help:
	@echo "Targets:"
	@echo "  deploy-munksgaard.me"
	@echo "  deploy-photos.munksgaard.me"
	@echo "  deploy-church"
	@echo "  update-munksgaard.me-gopher"
	@echo "  update-photos"

deploy:
	nix develop -c deploy '.'

deploy-munksgaard.me:
	nix develop -c deploy '.#"munksgaard.me".'

deploy-photos.munksgaard.me:
	nix develop -c deploy '.#"photos.munksgaard.me".'

deploy-sorgenfri.munksgaard.me:
	nix develop -c deploy '.#"sorgenfri.munksgaard.me".'

deploy-church:
	sudo nixos-rebuild switch --flake .#church

update-munksgaard.me-gopher:
	nix flake update munksgaard-gopher

update-photos:
	nix flake update photos

update-nixpkgs:
	nix flake update nixpkgs

update-digit:
	nix flake update digit

update-sorgenfri:
	nix flake update sorgenfri

update-home-manager:
	nix flake update home-manager
