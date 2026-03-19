{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/laptop
    ./hardware-configuration.nix
  ];

  networking.hostName = "hoare";

  laptop.steam.enable = true;
  laptop.elixir.enable = true;
  laptop.rust.enable = true;
  laptop.futhark.enable = true;
  laptop.ghostty.enable = true;
  laptop.sway.enable = true;
  laptop.tmux.enable = true;
  laptop.claude-code.enable = true;
  laptop.livebook.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?
}
