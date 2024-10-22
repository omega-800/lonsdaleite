{ self, pkgs, lib, config, ... }:
let
  inherit (lib)
    mkEnableOption mkOption types mkIf assertMsg pathIsRegularFile filterAttrs
    mapAttrsToList genAttrs mkForce mkDefault;
  inherit (builtins) readDir hasAttr mapAttrs readFile;
  inherit (self.inputs.apparmor-d.packages.${pkgs.system}) apparmor-d;
  # inherit (self.packages.${pkgs.system}) apparmor-d;
  cfg = config.security.apparmor-d;
  allProfiles = mapAttrsToList (n: v: n) (filterAttrs (n: v: v == "regular")
    (readDir "${apparmor-d}/etc/apparmor.d"));
  profileActionType = types.enum [ "disable" "complain" "enforce" ];
in
{
  options.security.apparmor-d = {
    enable = mkEnableOption "Enables apparmor.d support";

    allProfiles = mkOption {
      type = profileActionType;
      default = "disable";
      description = ''
        Can be set to "enforce" or "complain" to enable all profiles and set their flags to enforce or complain respectively
      '';
    };

    profiles = mkOption {
      type = types.attrsOf profileActionType;
      default = { };
      description = "Set of apparmor profiles to include from apparmor.d";
    };
  };

  config = mkIf cfg.enable {
    security.apparmor = {
      packages = [ apparmor-d ];
      policies =
        if (cfg.allProfiles != "disable") then
          (genAttrs allProfiles (name: {
            enable = mkDefault (if (hasAttr name cfg.profiles) then
              (cfg.profiles.${name} != "disable")
            else
              true);
            enforce = mkDefault ((if (hasAttr name cfg.profiles) then
              cfg.profiles.${name}
            else
              cfg.allProfiles) == "enforce");
            # profile = readFile "${apparmor-d}/etc/apparmor.d/${name}";
            profile = ''include "${apparmor-d}/etc/apparmor.d/${name}"'';
          }))
        else
          (mapAttrs
            (name: value: {
              enable = mkDefault (value != "disable");
              enforce = mkDefault (value == "enforce");
              profile =
                let file = "${apparmor-d}/etc/apparmor.d/${name}";
                in assert assertMsg (pathIsRegularFile file)
                  "profile ${name} not found in apparmor.d path (${file})";
                ''include "${file}"'';
            })
            cfg.profiles);
    };
    environment = {
      systemPackages = [ apparmor-d ];
      etc."apparmor/parser.conf".text = ''
        Optimize=compress-fast
      '';
    };
    # provide alternative boot entry in case apparmor rules break things
    specialisation.disabledApparmorD.configuration = {
      security.apparmor-d.enable = mkForce false;
      system.nixos.tags = [ "without-apparmor.d" ];
    };
  };
}
