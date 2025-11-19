{ pkgs
, config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.os.privilege;
  inherit (lib) mkIf mkEnableOption mkMerge;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkEnableDef;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.privilege =
    (mkEnableFrom [ "os" ] "Enables privileged access for trusted user")
    // {
      use-sudo = mkEnableOption "Uses sudo instead of doas";
      disable = mkEnableOption "Disables sudo/doas completely";
    };

  config = mkMerge [
    (mkIf cfg.enable {
      security = {
        sudo.enable = cfg.use-sudo;
        doas = lib.mkIf (!cfg.use-sudo) {
          enable = true;
          extraRules = [
            {
              users = if (usr != null) then [ usr ] else [ ];
              keepEnv = true;
              persist = true;
            }
          ];
        };
      };

      environment.systemPackages =
        if (!cfg.use-sudo) then
          [
            # TODO: lib.getExe doas yields error: "doas: not installed setuid"
            (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
            (pkgs.writeScriptBin "sudoedit" ''exec doas ${lib.getExe' pkgs.nano "rnano"} "$@"'')
            (pkgs.writeScriptBin "doasedit" ''exec doas ${lib.getExe' pkgs.nano "rnano"} "$@"'')
          ]
        else
          [ ];
    })
    # defaults should be more minimalistic in NixOS imho
    (mkIf cfg.disable { security.sudo.enable = false; })
    {
      assertions = [
        {
          assertion = !(cfg.enable && cfg.disable);
          message = ''
            One can only enable or disable privileged access, not both.
            Set one of config.lonsdaleite.os.privilege.{enable,disable} to false.
          '';
        }
      ];
    }
  ];
}
