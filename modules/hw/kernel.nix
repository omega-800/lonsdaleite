{
  config,
  lib,
  lon-lib,
  pkgs,
  ...
}:
let
  # TODO: research https://www.kicksecure.com/wiki/Hardened-kernel
  # implement https://kspp.github.io/Recommended_Settings
  # research https://outflux.net/blog/
  # https://kernsec.org/wiki/index.php/Linux_Kernel_Integrity
  # https://github.com/GrapheneOS/linux-hardened
  # https://wiki.gentoo.org/wiki/Integrity_Measurement_Architecture
  # https://www.qubes-os.org/doc/
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html#cold-boot-attacks
  # https://github.com/GrapheneOS/hardened_malloc#configuration
  # https://forums.gentoo.org/viewtopic-t-1084150-start-0.html
  # ZERO_ON_FREE
  # TODO: test on all architectures
  cfg = config.lonsdaleite.hw.kernel;
  inherit (lib) mkIf mkEnableOption;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
  version = "6.11.0"; # FIXME: get correct version
  #TODO:
  #hardenedConfig = import "${self.inputs.nixpkgs}/pkgs/os-specific/linux/kernel/hardened/config.nix" {
  #  inherit lib version;
  #  inherit (pkgs) stdenv;
  #};
  lonsdaleiteConfig = import ./kernelcfg.nix { inherit pkgs version; };
in
{
  options.lonsdaleite.hw.kernel =
    (mkEnableFrom [ "hw" ] "Hardens kernel")
    // (mkParanoiaFrom
      [ "hw" ]
      [
        ""
        ""
        ""
      ]
    )
    // {
      openpax = mkEnableOption "Uses the openpax kernel";
    };

  config = mkIf cfg.enable {
    # TODO: https://github.com/0xsirus/tirdad
    # TODO: research https://mjg59.dreamwidth.org/55105.html
    # https://a13xp0p0v.github.io/2018/11/04/stackleak.html
    boot = {
      modprobeConfig.enable = true;
      # TODO: research
      kernelPackages =
        if cfg.openpax then
          pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.callPackage (import ./openpax.nix) { }))
        else
          pkgs.linuxPackages_hardened;
      # TODO: research: does extraStructuredConfig in here override extraStructuredConfig from kernelPackages?
      kernelPatches = [
        {
          name = "lonsdaleite";
          patch = null;
          extraStructuredConfig = /*hardenedConfig // */ lonsdaleiteConfig;
          # extraConfig = "\n" + concatStringsSep "\n" (attrNames (filterAttrs
          #   (n: v: elem archMap.${removeSuffix "-linux" pkgs.system} v)
          #   kernelConfigs));
        }
      ];
    };
  };
}
