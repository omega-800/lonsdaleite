# https://github.com/Kicksecure/security-misc/blob/master/etc/modprobe.d/30_security-misc_disable.conf
{ config
, lib
, lon-lib
, pkgs
, ...
}:
let
  cfg = config.lonsdaleite.hw.modules;
  inherit (lib)
    mkIf
    mkAttrs
    mkMerge
    mapAttrs'
    nameValuePair
    flip
    concatMapStrings
    filterAttrs
    mapAttrs
    toInt
    mapAttrsToList
    concatLists
    attrValues
    ;
  inherit (lon-lib)
    mkDisableOption
    mkEnableFrom
    mkParanoiaFrom
    fileNamesNoExt
    mkEnableDef
    mkPersistDirs
    ;
  #modules = fileNamesNoExt ./modprobe;
  modules = import ./modules.nix;
in
{
  options.lonsdaleite.hw.modules =
    (mkEnableFrom [ "hw" ] "Disables kernel modules")
    // (mkParanoiaFrom [ "hw" ] [
      ""
      ""
      ""
    ])
    // (mapAttrs' (n: v: nameValuePair n (mkDisableOption "Disables ${n} modules")) modules)
    // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [ "/etc/modprobe.d" ];
    # already enabled by nixpkgs/nixos/modules/profiles/hardened.nix
    # security.lockKernelModules = true;
    # security.protectKernelImage = true;
    boot = {
      blacklistedKernelModules = concatLists (
        mapAttrsToList (n: v: concatLists (attrValues (filterAttrs (n': v': cfg.paranoia >= toInt n') v))) (
          filterAttrs (n: v: cfg.${n}) modules
        )
      );
      # because blacklist doesn't prevent modules from being loaded at runtime
      # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/deployment_guide/blacklisting_a_module#Blacklisting_a_Module
      extraModprobeConfig =
        (flip concatMapStrings config.boot.blacklistedKernelModules (name: ''
          install ${name} ${pkgs.toybox}/bin/true
        ''))
        +
        # Netfilter's automatic conntrack helper assignment is dangerous as it enables a lot of code in the kernel that parses incoming network packets which is potentially unsafe. 
        # https://home.regit.org/netfilter-en/secure-use-of-helpers/
        ''
          options nf_conntrack nf_conntrack_helper=0 
        '';
    };
  };
}
