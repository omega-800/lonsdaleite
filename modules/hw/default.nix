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
  options.lonsdaleite.hw =
    lon-lib.mkEnableFrom [ ] "hardens general hw components";
}
