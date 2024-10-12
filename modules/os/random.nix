{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.random;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  options.lonsdaleite.os.random =
    (mkEnableFrom [ "os" ] "Enables better entropy") // { };

  config = mkIf cfg.enable {
    # Get extra entropy since we disabled hardware entropy sources
    # Read more about why at the following URLs:
    # https://github.com/smuellerDD/jitterentropy-rngd/issues/27
    # https://blogs.oracle.com/linux/post/rngd1
    services.jitterentropy-rngd.enable = true;
    boot.kernelModules = [ "jitterentropy_rng" ];
  };
}
