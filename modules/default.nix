{ modulesPath
, lib
, lon-lib
, config
, ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mapAttrsToList
    filterAttrs
    ;
  inherit (lib.types)
    enum
    nullOr
    nonEmptyStr
    listOf
    ;
  inherit (lon-lib) mkParanoiaOptionDef mkDisableOption mkImport;
in
{
  imports = [
    ./net
    ./fs
    ./hw
    ./os
    ./sw
    # TODO: disable some of these if not needed
    # also remove dupes
    # "${modulesPath}/profiles/hardened.nix"
  ];

  options.lonsdaleite =
    let
      allUsers = mapAttrsToList (n: v: v.name) (filterAttrs (n: v: v.isNormalUser) config.users.users);
    in
    {
      enable = mkEnableOption ''
        Enables lonsdaleite. Enjoy the false sense of security.
      '';
      trustedUser = mkOption {
        type = nullOr nonEmptyStr;
        # causes infinite recursion when trying to use this config to mutate the users attrs
        # type = nullOr (enum allUsers);
        description = "The one and only trusted user. Or none, if you can't trust yourself either";
        default = null;
      };
      decapitated = mkDisableOption ''If the host will be running in "headless" mode, eg. a server. If you are expecting your gui to work, don't enable this option. If you are a tui-only gigachad then enjoy the extra security by enabling it.'';
      # TODO: implement
      priorities = mkOption {
        type = listOf (enum [
          "performance"
          "security"
          "privacy"
          "auditing"
        ]);
        default = [
          "privacy"
          "security"
        ];
        example = [
          "performance"
          "auditing"
        ];
      };
    }
    // (mkParanoiaOptionDef [
      "You still want your machine to be usable"
      "You like pretending to be schizo"
      "The feds are after you"
    ] 2);

  # because i'm too stupid to deal with infinite recursion
  config.assertions = [
    {
      assertion =
        config.lonsdaleite.trustedUser == null
        || config.users.users."${config.lonsdaleite.trustedUser}".isNormalUser;
      message = "`config.lonsdaleite.trustedUser' must be either null or normalUser";
    }
  ];
}
