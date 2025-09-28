{
  pkgs,
  lon-lib,
  lib,
  config,
  ...
}:
let
  cfg = config.lonsdaleite.net.proxychains;
  inherit (lib) mkIf;
  inherit (lon-lib)
    mkEnableFrom
    ;
in
{
  options.lonsdaleite.net.proxychains = mkEnableFrom [ "net" ] "Enables proxychains";
  programs.proxychains = mkIf cfg.enable {
    enable = true;
    quietMode = false;
    proxyDNS = true;
    package = pkgs.proxychains-ng;
    proxies = {
      tor = {
        type = "socks5";
        host = "127.0.0.1";
        port = 9050;
      };
    };
  };
}
