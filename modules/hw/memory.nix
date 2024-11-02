{ config, lib, lon-lib, ... }:
let
  cfg = config.lonsdaleite.hw.memory;
  inherit (lib) mkIf;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
in
{
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html#hardened-malloc
  options.lonsdaleite.hw.memory = (mkEnableFrom [ "hw" ] "Hardens memory")
    // (mkParanoiaFrom [ "hw" ] [ "" "" "" ]) // { };

  # TODO: if feature flag performance isn't set, lower these

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
      # TODO: set according to feature flags
      # already enabled by nixpkgs/nixos/modules/profiles/hardened.nix
      # forcePageTableIsolation = cfg.paranoia >= 1;
      # virtualisation.flushL1DataCache = if (cfg.paranoia >= 1) then "always" else null;
      # allowSimultaneousMultithreading = false;
    };

    # zram allows swapping to RAM by compressing memory. This reduces the chance
    # that sensitive data is written to disk, and eliminates it if zram is used
    # to completely replace swap to disk. Generally *improves* storage lifespan
    # and performance, there usually isn't a need to disable this.
    zramSwap.enable = true;
  };
}
