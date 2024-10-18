{ lib, lonLib, ... }:
# https://github.com/MatthewCash/nixos-config/blob/main/nixos/secureboot.nix
# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
# TODO: research, implement
{
  environment = lonLib.mkPersistDir [ "/etc/secureboot" ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
