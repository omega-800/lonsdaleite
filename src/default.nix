{ lib, ... }:
let inherit (lib) mkEnableOption mkOption types;
in {
  imports = [ ./fs ./hw ./net ./os ./sw ];
  options.lonsdaleite = {
    enable = mkEnableOption "enables lonsdaleite";
    paranoia = mkOption {
      description =
        "paranoia level. if you want your machine to still be usable set 0. if you think that the feds are after you, set 3.";
      type = types.enum [ 0 1 2 3 ];
      default = 2;
    };
  };
}
