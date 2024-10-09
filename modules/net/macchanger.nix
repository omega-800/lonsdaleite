{ pkgs, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.macchanger;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  #TODO: implement
  options.lonsdaleite.net.macchanger =
    (mkEnableFrom [ "net" ] "Enables MAC changer service")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    systemd.services.macchanger = {
      enable = true;
      description = "Change MAC address";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.macchanger}/bin/macchanger -r ######";
        ExecStop = "${pkgs.macchanger}/bin/macchanger -p ######";
        RemainAfterExit = true;
      };
    };
  };
}
