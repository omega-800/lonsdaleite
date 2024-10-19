{ config, lib, lon-lib, pkgs, ... }:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkPersistDirs;
in
{
  # https://gitlab.com/apparmor/apparmor
  # https://github.com/roddhjav/apparmor.d
  # TODO: research
  options.lonsdaleite.sw.apparmor = (mkEnableFrom [ "sw" ] "Enables apparmor")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [ "/etc/apparmor" ];
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      #TODO: implement? write my own? 
      includes = { };
      policies = {
        test = {
          enable = true;
          enforce = false;
          profile = ''
            ${pkgs.vim}/bin/vim {

            }
          '';
        };
      };
    };
  };
}
