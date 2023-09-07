help:
	@echo "Targets:"
	@echo "  deploy-munksgaard.me"
	@echo "  deploy-photos.munksgaard.me"
	@echo "  deploy-church"
	@echo "  update-munksgaard.me-gopher"
	@echo "  update-photos"

deploy:
	nix run github:serokell/deploy-rs '.'

deploy-munksgaard.me:
	nix run github:serokell/deploy-rs '.#"munksgaard.me".'

deploy-photos.munksgaard.me:
	nix run github:serokell/deploy-rs '.#"photos.munksgaard.me".'

deploy-church:
	sudo nixos-rebuild switch --flake .#church

update-munksgaard.me-gopher:
	nix flake lock --update-input munksgaard-gopher

update-photos:
	nix flake lock --update-input photos

update-nixpkgs:
	nix flake lock --update-input nixpkgs
