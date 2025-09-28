# TODO https://github.com/NixOS/nixpkgs/issues/18176
{
  lon-lib,
  lib,
  config,
  ...
}:
let
  cfg = config.lonsdaleite.net.tcpcrypt;
  inherit (lib) mkIf;
  inherit (lon-lib)
    mkEnableFrom
    ;
in
{
  options.lonsdaleite.net.tcpcrypt = mkEnableFrom [ "net" ] "Enables tcpcrypt";
  config = mkIf cfg.enable {
    networking.tcpcrypt.enable = true;
  };
}
