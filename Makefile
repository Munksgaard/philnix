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
	nix flake lock --update-input munksgaard-gopher

update-photos:
	nix flake lock --update-input photos

update-nixpkgs:
	nix flake lock --update-input nixpkgs

update-digit:
	nix flake lock --update-input digit
