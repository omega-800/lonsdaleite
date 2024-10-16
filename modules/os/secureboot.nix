{ lib, lonLib, ... }:
# https://github.com/MatthewCash/nixos-config/blob/main/nixos/secureboot.nix

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
