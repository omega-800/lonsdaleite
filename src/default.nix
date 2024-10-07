{ lib, ... }: {
  imports = [ ./fs ./hw ./net ./os ./sw ];
  options.lonsdaleite.enable = lib.mkEnableOption "enables lonsdaleite";
}
