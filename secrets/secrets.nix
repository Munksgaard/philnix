let
  munksgaard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlapwwXZyp/qTm1y9CA5WLVL33TAAznj5FkZW4/Ftvu";
  server-root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxPR0Civ+OXbgju3bGzKP/NZe4/BRrPTqpAGnL7uik5";
  photos-root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQbpVcIFvROq0kwPSwfub0TcuWnwXJ6uO1nY0d+N0xO";
  sorgenfri-test-root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDQ3tfiixfEb8cxF0byyWUmgxh01cE5jEbTO6NbPAp6";
in
{
  "matrix-extra-conf.age".publicKeys = [ munksgaard server-root ];
  "gitea-mailer-password.age".publicKeys = [ munksgaard server-root ];
  "vaultwarden-environment.age".publicKeys = [ munksgaard server-root ];
  "photos-secret-key.age".publicKeys = [ munksgaard server-root photos-root ];
  "photos-secret-key-base.age".publicKeys = [ munksgaard sorgenfri-test-root ];
  "photos-smtp-password.age".publicKeys = [ munksgaard server-root photos-root sorgenfri-test-root ];
  "foundry-password.age".publicKeys = [ munksgaard server-root ];
  "sorgenfri-s3-access-key.age".publicKeys = [  munksgaard sorgenfri-test-root ];
  "sorgenfri-s3-secret-access-key.age".publicKeys = [  munksgaard sorgenfri-test-root ];
}
