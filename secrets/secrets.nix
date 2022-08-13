let
  munksgaard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu";
  server-root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFv07cWCKk60J1+L/elzpxb/HHXN+FPBrsqQ1FXdkTxb";
in
{
  "matrix-extra-conf.age".publicKeys = [ munksgaard server-root ];
  "gitea-mailer-password.age".publicKeys = [ munksgaard server-root ];
  "vaultwarden-environment.age".publicKeys = [ munksgaard server-root ];
}
