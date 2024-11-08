{ lib
, lon-lib
, config
, ...
}:
let
  inherit (lib) mkIf mkForce optionals;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
  cfg = config.lonsdaleite.os.nixos;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.nixos =
    (mkEnableFrom [ "os" ] "Hardens NixOS")
    // (mkParanoiaFrom [ "os" ] [
      ""
      ""
      ""
    ]);
  config = mkIf cfg.enable {
    nix = {
      # TODO: research flakes vs channels in the context of security / immutability
      # channel.enable = false; 

      # Avoid disk full issues
      gc = {
        automatic = true;
        dates = "02:00";
        randomizedDelaySec = "30min";
      };
      optimise = {
        automatic = true;
        dates = [ "03:00" ];
      };
      settings = {
        # TODO: allow wheel if configured
        trusted-users = optionals (usr != null && cfg.paranoia == 0) [
          usr
          "root"
        ]; # default is [ "root" ]
        # override nixos/modules/profiles/hardened
        allowed-users = mkForce (if usr != null then [ usr ] else [ ]);
        sandbox = true;
        sandbox-fallback = cfg.paranoia == 0;
        require-drop-supplementary-groups = cfg.paranoia == 2;
        restrict-eval = cfg.paranoia == 2;
        extra-sandbox-paths = lib.optionals (cfg.paranoia == 0) [
          "/dev"
          "/proc"
        ];
        allow-dirty = cfg.paranoia == 0;
        show-trace = true;
        require-sigs = true; # should be default already
        log-lines = 25;
        pure-eval = cfg.paranoia > 0;
        # max-jobs = "auto";
        # Avoid disk full issues
        auto-optimise-store = true;
        max-free = 3000 * 1024 * 1024;
        min-free = 512 * 1024 * 1024;
      };
    };
  };
}
