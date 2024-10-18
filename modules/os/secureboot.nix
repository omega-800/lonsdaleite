{ config, lib, lonLib, ... }:
# https://github.com/MatthewCash/nixos-config/blob/main/nixos/secureboot.nix
# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
# TODO: research, implement
let
  cfg = config.lonsdaleite.os.secureboot;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkPersistDirs;
in
{
  options.lonsdaleite.os.secureboot =
    (mkEnableFrom [ "os" ] "Enables secureboot") // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [ "/etc/secureboot" ];

    boot = {
      loader.systemd-boot.enable = lib.mkForce false;

      # TODO: flake input
      # lanzaboote = {
      #   enable = true;
      #   pkiBundle = "/etc/secureboot";
      # };
    };
  };
}
