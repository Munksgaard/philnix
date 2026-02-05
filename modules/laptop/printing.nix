{ ... }:

{
  services.printing = {
    enable = true;
  };

  hardware.printers.ensurePrinters = [
    {
      description = "Leaf";
      deviceUri = "ipp://10.0.0.46/ipp";
      model = "everywhere";
      name = "Leaf_NixOS";
      ppdOptions = {
        PageSize = "A4";
      };
    }
  ];

}
