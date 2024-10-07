{ lib, config, ... }:
let
  rootConfig = config.lonsdaleite;
  inherit (lib) mkOption attrByPath concatImapStringsSep;
  inherit (lib.types) bool enum;
in
rec {
  paranoiaType = enum [ 0 1 2 ];

  mkEnableDef = default: description:
    mkOption {
      inherit default description;
      type = bool;
    };

  mkEnableFrom = path: description: {
    enable = mkEnableDef (attrByPath (path ++ [ "enable" ]) false rootConfig)
      description;
  };

  mkParanoiaOptionDef = descriptions: default: {
    paranoia = mkOption {
      inherit default;
      description =
        concatImapStringsSep "\n" (i: d: "${toString i}: ${d}") descriptions;
      type = paranoiaType;
    };
  };

  mkParanoiaOption = descriptions:
    mkParanoiaOptionDef descriptions rootConfig.paranoia;
}
