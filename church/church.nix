{ config, pkgs, lib, ... }:

{
  imports = [ ../modules/laptop ./hardware-configuration.nix ];

  networking.hostName = "church";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  # Intel GPU configuration
  laptop.intelGpu.enable = true;

  # Enable optional features used on church
  laptop.smlTools.enable = true;
  laptop.redshift.enable = true;
}
