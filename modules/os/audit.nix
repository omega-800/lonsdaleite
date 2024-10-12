{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.audit;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  #TODO: research
  options.lonsdaleite.os.audit = (mkEnableFrom [ "os" ] "Enables audit") // { };

  config = mkIf cfg.enable {
    security = {
      auditd.enable = true;
      audit = {
        enable = true;
        rules = [ "-a exit,always -F arch=b64 -S execve" ];
      };
    };
  };
}
