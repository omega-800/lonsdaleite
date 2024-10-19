{ lib, config, ... }:
let
  rootConfig = config.lonsdaleite;
  inherit (lib)
    mkOption attrByPath concatImapStringsSep concatStringsSep splitString
    findFirst mapAttrsToList filterAttrs take length mkMerge mkIf hasPrefix
    hasSuffix;
  inherit (lib.types) bool enum ints;
  const = import ./const.nix;
in
rec {
  inherit const;

  paranoiaType = ints.between 0 2;

  mkHighDefault = val: lib.mkOverride 900 val;
  mkHigherDefault = val: lib.mkOverride 800 val;

  userByName = name:
    findFirst (u: u.name == name) null
      (mapAttrsToList (n: v: v) config.users.users);

  mkEnableDef = default: description:
    mkOption {
      inherit default description;
      type = bool;
    };

  mkEnableFrom = path: description: {
    enable = mkEnableDef (attrByPath (path ++ [ "enable" ]) false rootConfig)
      (description
        + "Defaults to: config.lonsdaleite.${concatStringsSep "." path}enable");
  };

  mkParanoiaOptionWithInfo = descriptions: default: info: {
    paranoia = mkOption {
      inherit default;
      description = ''
        ${concatImapStringsSep "\n" (i: d:
          "${toString i}: ${
            (if ((builtins.match "^$" d) == null) then d else "no effect")
          }") descriptions}
        ${info}
      '';
      type = paranoiaType;
    };
  };

  mkParanoiaOptionDef = descriptions: default:
    mkParanoiaOptionWithInfo descriptions default "";

  mkParanoiaOption = descriptions:
    mkParanoiaOptionDef descriptions rootConfig.paranoia;

  mkParanoiaFrom = path: descriptions:
    mkParanoiaOptionWithInfo descriptions
      (attrByPath (path ++ [ "paranoia" ]) 2 rootConfig)
      "Defaults to: config.lonsdaleite.${concatStringsSep "." path}.paranoia";

  mkLink = name: url: "[${name}](${url})";
  mkSrcLink = url: mkLink "Source" url;
  mkCopyLink = name: url: mkLink "Copied from `${name}`" url;
  mkMineralLink = line:
    mkCopyLink "nix-mineral"
      "https://github.com/cynicsketch/nix-mineral/blob/6c6e7886925e81b39e9d85c74d8c0b1c91889b96/nix-mineral.nix#L${
      toString line
    }";

  fileNamesNoExt = dir:
    mapAttrsToList
      (n: v:
        let split = splitString "." n;
        in concatStringsSep "." (take ((length split) - 1) split))
      (filterAttrs (n: v: v == "regular") (builtins.readDir dir));

  mkEtcPersist = file: content:
    mkMerge [
      { etc."${file}".text = content; }
      (mkIf config.lonsdaleite.fs.impermanence.enable {
        persistence."/nix/persist".files = [ "/etc/${file}" ];
      })
    ];
  mkPersistFiles = files:
    mkIf config.lonsdaleite.fs.impermanence.enable {
      persistence."/nix/persist" = { inherit files; };
    };
  mkPersistDirs = directories:
    mkIf config.lonsdaleite.fs.impermanence.enable {
      persistence."/nix/persist" = { inherit directories; };
    };

  # yeah nice try, yields infinite recursion
  mkImport = dir:
    map (n: v: n) (filterAttrs
      (n: v:
        (!hasPrefix "_" n) && ((v == "regular" && hasSuffix ".nix" n)
        || (v == "directory" && builtins.pathExists "${dir}/${n}/default.nix")))
      (builtins.readDir dir));
}
