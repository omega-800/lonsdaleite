{ pkgs, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.privilege;
  inherit (lib) mkIf mkEnableOption mkMerge;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkEnableDef;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.privilege =
    (mkEnableFrom [ "os" ] "Enables privileged access for normal users") // {
      use-sudo = mkEnableOption "Uses sudo instead of doas";
      disable = mkEnableDef (!cfg.enable) "Disables sudo/doas completely";
    };

  config = mkMerge [
    (mkIf cfg.enable {
      security = {
        sudo.enable = cfg.use-sudo;
        doas = lib.mkIf (!cfg.use-sudo) {
          enable = true;
          extraRules = [{
            users = if (usr != null) then [ usr ] else [ ];
            keepEnv = true;
            persist = true;
          }];
        };
      };

      environment.systemPackages =
        if (!cfg.use-sudo) then [
          (pkgs.writeScriptBin "sudo" ''exec ${lib.getExe pkgs.doas} "$@"'')
          (pkgs.writeScriptBin "sudoedit" ''
            exec ${lib.getExe pkgs.doas} ${lib.getExe' pkgs.nano "rnano"} "$@"'')
          (pkgs.writeScriptBin "doasedit" ''
            exec ${lib.getExe pkgs.doas} ${lib.getExe' pkgs.nano "rnano"} "$@"'')
        ] else
          [ ];
    })
    # defaults should be more minimalistic in NixOS imho
    (mkIf cfg.disable { security.sudo.enable = false; })
  ];
}
