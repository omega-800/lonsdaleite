{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.hw.kernel;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
  disabled_modules = [
    # TODO: modules.nix
    ""
  ];
in {
  options.lonsdaleite.hw.kernel = (mkEnableFrom [ "hw" ] "Hardens kernel")
    // (mkParanoiaFrom [ "hw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    boot = {
      modprobeConfig.enable = true;
      blacklistedKernelModules = disabled_modules;
    };
    environment.etc."modprobe.d/nixos-disable" =
      concatMapStringsSep (s: "install ${s} /bin/false") "\n" disabled_modules;
  };
}
