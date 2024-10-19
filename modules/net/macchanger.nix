{ pkgs, config, lib, lon-lib, ... }:
let
  cfg = config.lonsdaleite.net.macchanger;
  inherit (lib) mkIf concatMapStrings mkOption attrNames;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
in {
  options.lonsdaleite.net.macchanger =
    (mkEnableFrom [ "net" ] "Enables MAC changer service") // {
      interfaces = mkOption {
        description = "Interfaces to change MAC address on";
        type = listOf nonEmptyStr;
        default = attrNames config.networking.interfaces;
      };
    };

  config = mkIf (cfg.enable && (builtins.length cfg.interfaces > 0)) {
    systemd.services.macchanger = {
      enable = true;
      description = "Change MAC address";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = concatMapStrings (i: ''
          ${pkgs.macchanger}/bin/macchanger -r ${i}
        '') cfg.interfaces;
        ExecStop = concatMapStrings (i: ''
          ${pkgs.macchanger}/bin/macchanger -p ${i}
        '') cfg.interfaces;
        RemainAfterExit = true;
      };
    };
  };
}
