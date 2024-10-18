{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.audit;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in
{
  # https://wiki.archlinux.org/title/Audit_framework
  #TODO: research
  options.lonsdaleite.os.audit = (mkEnableFrom [ "os" ] "Enables audit")
    // (mkParanoiaFrom [ "os" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    security = {
      auditd.enable = true;
      audit = {
        enable = if cfg.paranoia == 2 then "lock" else true;
        rules = [ "-a exit,always -F arch=b64 -S execve" ];
      };
    };
  };
}
