{ pkgs, ... }:
{
  programs.proxychains = {
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
