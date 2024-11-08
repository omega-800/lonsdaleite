{ lib
, lon-lib
, config
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
  cfg = config.lonsdaleite.sw.nixpkgs;
in
{
  options.lonsdaleite.sw.nixpkgs =
    (mkEnableFrom [ "sw" ] "Hardens nixpkgs")
    // (mkParanoiaFrom [ "sw" ] [
      ""
      ""
      ""
    ]);
  config = mkIf cfg.enable {
    nixpkgs.config = {
      warnUndeclaredOptions = true;
      # WARNING: all of these can cause mass rebuilds
      checkMeta = cfg.paranoia == 2;
      doCheckByDefault = cfg.paranoia != 0;
      strictDepsByDefault = cfg.paranoia != 0;
      structuredAttrsByDefault = cfg.paranoia != 0;
    };
  };
}
