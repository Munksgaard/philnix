help:
	@echo "Targets:"
	@echo "  deploy-munksgaard.me"
	@echo "  deploy-church"
	@echo "  update-munksgaard.me-gopher"

deploy-munksgaard.me:
	nix run github:serokell/deploy-rs '.#"munksgaard.me".'

deploy-church:
	sudo nixos-rebuild switch .#church

update-munksgaard.me-gopher:
	nix flake lock --update-input munksgaard-gopher
