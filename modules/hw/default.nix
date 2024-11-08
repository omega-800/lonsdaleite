{ lon-lib, ... }:
{
  imports = [
    ./bluetooth.nix
    ./kernel.nix
    ./memory.nix
    ./misc.nix
    ./modprobe.nix
    ./sysctl.nix
  ];
  options.lonsdaleite.hw = lon-lib.mkEnableFrom [ ] "hardens general hw components";
}
