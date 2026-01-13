{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [ wl-mirror slurp rofi pipectl ];
}
