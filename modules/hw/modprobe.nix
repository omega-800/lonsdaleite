# https://github.com/Kicksecure/security-misc/blob/master/etc/modprobe.d/30_security-misc_disable.conf
{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.hw.modules;
  inherit (lib) mkIf mkAttrs mkMerge mapListToAttrs;
  inherit (lonLib)
    mkEnableFrom mkParanoiaFrom fileNamesNoExt mkEnableDef mkPersistDirs;
  modules = fileNamesNoExt ./modprobe;
in
{
  options.lonsdaleite.hw.modules =
    (mkEnableFrom [ "hw" ] "Disables kernel modules")
    // (mkParanoiaFrom [ "hw" ] [ "" "" "" ]) // (mapListToAttrs
      (m: {
        name = "disable-${m}";
        value = mkEnableDef true "Disables ${m} module";
      })
      modules);

  config = mkIf cfg.enable {
    environment = mkMerge [
      {
        etc = mapListToAttrs
          (m: {
            name = "modprobe.d/${m}.conf";
            value.text = builtins.readFile ./modprobe/${m}.conf;
          })
          (builtins.filter (m: config.lonsdaleite.hw.modules."disable-${m}")
            modules);
      }
      (mkPersistDirs [ "/etc/modprobe.d" ])
    ];
  };
}
