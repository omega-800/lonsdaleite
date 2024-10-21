{ self, pkgs, lib, config, ... }:
let
  inherit (lib)
    mkEnableOption mkOption types mkIf assertMsg pathIsRegularFile filterAttrs
    mapAttrsToList genAttrs;
  inherit (builtins) readDir hasAttr mapAttrs;
  inherit (self.inputs.apparmor-d.packages.${pkgs.system}) apparmor-d;
  cfg = config.security.apparmor-d;
  allProfiles = mapAttrsToList (n: v: n) (filterAttrs (n: v: v == "regular")
    (readDir "${apparmor-d}/etc/apparmor.d"));
in
{
  options.security.apparmor-d = {
    enable = mkEnableOption "Enables apparmor.d support";
    enableAllProfiles = mkEnableOption ''
      Enables all of the profiles in apparmor.d
    '';
    enforceAllProfiles = mkEnableOption ''
      Enforces all of the profiles in apparmor.d
    '';

    profiles = mkOption {
      type = types.attrsOf (types.enum [ "disable" "complain" "enforce" ]);
      default = { };
      description = "set of apparmor profiles to include from apparmor.d";
    };
  };

  config = mkIf cfg.enable {
    security.apparmor = {
      # doesn't do much apart from including ${package}/etc/apparmor.d 
      # in /etc/apparmor/{parser,logprof}.conf 
      # is this needed for apparmor to recognize these profiles? 
      packages = [ apparmor-d ];
      policies =
        if cfg.enableAllProfiles then
          (genAttrs allProfiles (name: {
            enable =
              if (hasAttr name cfg.profiles) then
                (cfg.profiles.${name} != "disable")
              else
                true;
            enforce =
              if (hasAttr name cfg.profiles) then
                (cfg.profiles.${name} == "enforce")
              else
                cfg.enforceAllProfiles;
            # profile = readFile "${apparmor-d}/etc/apparmor.d/${n}";
            profile = ''include "${apparmor-d}/etc/apparmor.d/${name}"'';
          }))
        else
          (mapAttrs
            (name: value: {
              enable = value != "disable";
              enforce = value == "enforce";
              profile =
                let file = "${apparmor-d}/etc/apparmor.d/${name}";
                in assert assertMsg (pathIsRegularFile file)
                  "profile ${name} not found in apparmor.d path (${file})";
                ''include "${file}"'';
            })
            cfg.profiles);
    };
    environment = {
      # is this necessary if apparmor-d is included inside of security.apparmor.packages?
      systemPackages = [ apparmor-d ];
      etc."apparmor/parser.conf".text = ''
        Optimize=compress-fast
      '';
    };
  };
}
