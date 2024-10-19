{ lonLib, ... }: {
  imports =
    [ ./apparmor.nix ./firejail.nix ./gpg.nix ./isolate.nix ./wrappers.nix ];
  options.lonsdaleite.sw =
    lonLib.mkEnableFrom [ ] "hardens or enables secured software";
  # again, NixOS and it's strange defaults... but who am i to complain, i'm writing a very opinionated NixOS module myself at this very moment
  config.environment.defaultPackages = [ ];
}
