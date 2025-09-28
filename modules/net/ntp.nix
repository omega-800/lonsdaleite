{
  lon-lib,
  lib,
  config,
  ...
}:
let
  cfg = config.lonsdaleite.net.ntp;
  inherit (lib) mkIf;
  inherit (lon-lib)
    mkEnableFrom
    ;
in
{
  # TODO: research
  # NTP is very insecure as it is unauthenticated and unencrypted.
  # time syncing is important though, so i'll have to look into alternatives
  # sdwdate (Whonix) https://www.whonix.org/wiki/Sdwdate
  # https://gitlab.com/madaidan/secure-time-sync

  options.lonsdaleite.net.ntp = mkEnableFrom [ "net" ] "Hardens ntp";
  config.services = mkIf cfg.enable {
    ntp.enable = false;
    timesyncd.enable = false;
    chrony.enable = false;
  };
}
