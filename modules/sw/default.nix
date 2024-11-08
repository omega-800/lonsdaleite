{ lon-lib, ... }:
{
  imports = [
    ./apparmor.nix
    ./firejail.nix
    ./gpg.nix
    ./isolate.nix
    ./wrappers.nix
  ];
  options.lonsdaleite.sw = lon-lib.mkEnableFrom [ ] "hardens or enables secured software";
  # again, NixOS and it's strange defaults... but who am i to complain, i'm writing a very opinionated NixOS module myself at this very moment
  config = {
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
