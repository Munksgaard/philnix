# Replace this entire file with the output of nixos-generate-config on meier.
# Do not invent disk UUIDs or reuse another computer's hardware configuration.
{ ... }:

{
  assertions = [
    {
      assertion = false;
      message = "meier: replace meier/hardware-configuration.nix with the Lenovo's generated hardware configuration and select a bootloader in meier/meier.nix before installing.";
    }
  ];
}
