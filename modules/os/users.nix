{ lib
, lon-lib
, config
, ...
}:
let
  cfg = config.lonsdaleite.os.users;
  inherit (lib) mkIf mkEnableOption mkMerge;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkEnableDef;
  inherit (builtins) filter hasAttr;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.users = (mkEnableFrom [ "os" ] "Hardens users") // {
    lock-root = mkEnableOption "Lock root user";
    # TODO: wheel = mkEnableOption "Allow @wheel to be trusted";

  };
  config = mkIf cfg.enable {
    users = {
      # TODO: add to README that this requires --no-root-passwd on install
      # and passwords to be set declaratively for all users
      mutableUsers = false;
      users = mkMerge [
        (mkIf cfg.lock-root { root.hashedPassword = "!"; })
        (mkIf (usr != null) {
          ${usr} = {
            extraGroups = (
              filter (group: hasAttr group config.users.groups) [
                "wheel"
                "video"
                "audio"
                "podman"
                "adbusers"
              ]
            );
          };
        })
      ];
    };
  };
}
