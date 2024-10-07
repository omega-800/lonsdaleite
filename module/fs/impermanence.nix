{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.fs.impermanence;
  inherit (lib) mkIf mkMerge mkDefault mkEnableOption;
  inherit (lonLib) mkEnableFrom mkParanoiaOption mkEnableDef;
  isFsEnabled = fsType:
    (builtins.elem fsType config.boot.initrd.supportedFilesystems)
    || config.fileSystems."/".fsType == fsType;
in
{
  options.lonsdaleite.fs.impermanence =
    (mkEnableFrom [ "fs" ] "makes your / go whoosh every time you reboot") // {
      btrfs-integration =
        mkEnableDef (isFsEnabled "btrfs") "enables btrfs support";
      zfs-integration = mkEnableDef (isFsEnabled "zfs") "enables zfs support";
      ext4-integration = mkEnableDef (isFsEnabled "ext4") "enables lvm support";
    };

  #TODO: implement
  config = mkIf cfg.enable { };
}
