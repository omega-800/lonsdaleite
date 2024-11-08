{ pkgs
, config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.sw.gpg;
  inherit (lib) mkIf;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
in
{
  # TODO: research
  options.lonsdaleite.sw.gpg =
    (mkEnableFrom [ "sw" ] "Enables gpg agent")
    // (mkParanoiaFrom [ "sw" ] [
      ""
      ""
      ""
    ])
    // { };

  config = mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-tty;
      settings = {
        default-cache-ttl = 600;
      };
    };
  };
}
