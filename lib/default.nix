{ lib, ... }: {
  mkParentDefEnableOption = description: path: {
    enable = lib.mkOption {
      inherit description;
      type = lib.types.bool;
      default = lib.attrByPath false (path ++ [ "enable" ]);
    };
  };
}
