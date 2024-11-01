{ lon-lib, ... }: {
  imports = [
    ./grsec.nix
    ./kernel.nix
    ./memory.nix
    ./misc.nix
    ./modprobe.nix
    ./sysctl.nix
    ./tpm.nix
  ];
  options.lonsdaleite.os =
    lon-lib.mkEnableFrom [ ] "hardens general hw components";
}
