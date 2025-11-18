{ lib, config, lon-lib, ... }:
let
  cfg = config.lonsdaleite.sw.disable;
  inherit (lib) mkIf;
  inherit (lon-lib)
    mkEnableFrom
    ;
in
{
  options.lonsdaleite.sw.disable = mkEnableFrom [ "sw" ] "Disables rarely used programs";
  # again, NixOS and it's strange defaults... but who am i to complain, i'm writing a very opinionated NixOS module myself at this very moment
  config = mkIf cfg.enable {
    environment.defaultPackages = [ ];
    programs = {
      command-not-found.enable = false;
      nano.enable = false;
    };
    # security.chromiumSuidSandbox.enable = true;
    # TODO: disable services which are enabled by default
    # let lib = (import <nixpkgs> {}).lib; in lib.mapAttrs (n: v: n) (lib.filterAttrs (n: v: (lib.hasAttr "enable" v) && (lib.hasAttr "default" v.enable) && (v.enable.default == true)) nixosConfigurations.nixie.options.services)
    # { graphical-desktop = "graphical-desktop"; libinput = "libinput"; logrotate = "logrotate"; lvm = "lvm"; nscd = "nscd"; udev = "udev"; }

  };
}
