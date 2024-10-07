{ lib, lonLib, ... }: {
  imports = [ ./fs ./hw ./net ./os ./sw ];

  options.lonsdaleite = {
    enable = lib.mkEnableOption "enables lonsdaleite";
    paranoia = lonLib.mkParanoiaOptionDef [
      "you still want your machine to be usable"
      "you like to pretend to be schizo"
      "the feds are after you"
    ] 2;
  };
}
