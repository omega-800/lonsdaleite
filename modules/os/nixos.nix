{
  lib,
  lon-lib,
  config,
  pkgs,
  ...
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
    // (mkParanoiaFrom
      [ "os" ]
      [
        ""
        ""
        ""
      ]
    );
  config = mkIf cfg.enable {

    # Make builds to be more likely killed than important services.
    # 100 is the default for user slices and 500 is systemd-coredumpd@
    # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;
    nix = {
      # TODO:
      # daemonCPUSchedPolicy = lib.mkDefault "batch";
      # daemonIOSchedClass = lib.mkDefault "idle";
      # daemonIOSchedPriority = lib.mkDefault 7;
      package = pkgs.lix;
      # TODO: research flakes vs channels in the context of security / immutability
      # channel.enable = false;

      # Avoid disk full issues
      gc = {
        automatic = true;
        dates = "02:00";
        randomizedDelaySec = "1h";
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
        builders-use-substitutes = true;
        # Fallback quickly if substituters are not available.
        connect-timeout = 5;
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
        # Avoid disk full issues
        max-free = 3000 * 1024 * 1024;
        min-free = 512 * 1024 * 1024;
      };
    };
  };
}
