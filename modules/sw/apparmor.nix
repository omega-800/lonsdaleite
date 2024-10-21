{ self, config, lib, lon-lib, pkgs, ... }:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf concatMapAttrs;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkPersistDirs mkEtcPersist;
  inherit (builtins) match elemAt readDir readFile;
  inherit (self.inputs.apparmor-d.packages.${pkgs.system}) apparmor-d;
in
{
  imports = [ ./apparmor-d-module.nix ];

  # https://gitlab.com/apparmor/apparmor
  # https://github.com/roddhjav/apparmor.d
  # TODO: research
  options.lonsdaleite.sw.apparmor = (mkEnableFrom [ "sw" ] "Enables apparmor")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [
      "/etc/apparmor"
    ]
      #   // (mkEtcPersist "apparmor/parser.conf" ''
      #   Optimize=compress-fast
      # '')
    ;
    security.apparmor =
      let
        # FIXME: there HAS to be a better way to do this
        # readFilesRec = path:
        #   concatMapAttrs
        #     (name: value:
        #       if value == "regular" then {
        #         "${elemAt (match ".*/etc/apparmor.d/(.*)" "${path}/${name}") 0}" =
        #           readFile "${path}/${name}";
        #       } else if value == "directory" then
        #         (readFilesRec "${path}/${name}")
        #       else
        #         { })
        #     (readDir path);
      in
      {
        enable = true;
        killUnconfinedConfinables = true;
        # packages = [ apparmor-d ];
        # includes = readFilesRec "${apparmor-d}/etc/apparmor.d";
        # policies = {
        #   test = {
        #     enable = true;
        #     enforce = false;
        #     profile = ''
        #       ${pkgs.vim}/bin/vim {
        #
        #       }
        #     '';
        #   };
        # };
      };
    security.apparmor-d = {
      enable = true;
      enableAllProfiles = true;
    };
  };
}
