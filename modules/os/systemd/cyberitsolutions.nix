{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf mkMerge;
  default-deny = {
    PrivateNetwork = true;
    CapabilityBoundingSet = "";
    RestrictAddressFamilies = [ "AF_UNIX" ];
    RestrictNamespaces = true;
    DevicePolicy = "closed";
    IPAddressDeny = "any";
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "@resources"
    ];
    RestrictRealtime = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    UMask = "0077";
  };
in
{
  # https://github.com/cyberitsolutions/prisonpc-systemd-lockdown/tree/main/systemd/system/0-EXAMPLES
  # https://github.com/cyberitsolutions/bootstrap2020/
  systemd.services = mkIf cfg.enable {
    # https://github.com/cyberitsolutions/prisonpc-systemd-lockdown/blob/main/systemd/system/postgresql%40.service.d/40-opt-in-allow.conf
    "postgresql@".serviceConfig =
      # TODO: merge lists
      default-deny // {
        User = "";
        PrivateUsers = false;
        CapabilityBoundingSet = [
          "CAP_DAC_OVERRIDE"
          "CAP_CHOWN"
          "CAP_SETUID"
          "CAP_SETGID"
        ];
        SystemCallFilter = [
          "@setuid"
          "@chown"
        ];
        PrivateNetwork = false;
        IPAddressDeny = "";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        ReadWritePaths = [
          "/run/postgresql"
          "/var/lib/postgresql"
          "/var/log/postgresql"
        ];
      };
  };
}
