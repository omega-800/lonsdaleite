{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.hw.memory;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in
{
  options.lonsdaleite.hw.memory = (mkEnableFrom [ "hw" ] "Hardens memory")
    // (mkParanoiaFrom [ "hw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    environment = {
      memoryAllocator.provider =
        if (cfg.paranoia == 0) then
          "libc"
        else if (cfg.paranoia == 1) then
          "scudo"
        else
          "graphene-hardened";
      variables =
        mkIf (cfg.paranoia == 1) { SCUDO_OPTIONS = "ZeroContents=1"; };
    };
    security = {
      forcePageTableIsolation = cfg.paranoia == 2;
      virtualisation.flushL1DataCache =
        if (cfg.paranoia == 2) then "always" else null;
    };

    # zram allows swapping to RAM by compressing memory. This reduces the chance
    # that sensitive data is written to disk, and eliminates it if zram is used
    # to completely replace swap to disk. Generally *improves* storage lifespan
    # and performance, there usually isn't a need to disable this.
    zramSwap.enable = true;
  };
}
