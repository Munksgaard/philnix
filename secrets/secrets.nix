let
  munksgaard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu";
in
{
  "matrix-extra-conf.age".publicKeys = [ munksgaard ];
  "gitea-mailer-password.age".publicKeys = [ munksgaard ];
  "vaultwarden-environment.age".publicKeys = [ munksgaard ];
}
