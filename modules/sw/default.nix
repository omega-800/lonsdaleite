{ lon-lib, ... }:
{
  imports = [
    ./apparmor.nix
    ./firejail.nix
    ./gpg.nix
    ./isolate.nix
    ./wrappers.nix
    ./compiler.nix
    ./disable.nix
  ];
  options.lonsdaleite.sw = lon-lib.mkEnableFrom [ ] "hardens or enables secured software";
}
