{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  # https://github.com/cyberitsolutions/prisonpc-systemd-lockdown/tree/main/systemd/system/0-EXAMPLES
  # https://github.com/cyberitsolutions/bootstrap2020/
  systemd.services = mkIf cfg.enable { };
}
