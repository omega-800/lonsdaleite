{ self, config, lib, lon-lib, pkgs, ... }:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf concatMapAttrs;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkPersistDirs mkEtcPersist;
  inherit (builtins) match elemAt readDir readFile;
in
{
  imports = [ ./apparmor-d-module.nix ./test.nix ];

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
        policies = {
          test = {
            enable = false;
            enforce = false;
            profile = ''
              # apparmor.d - Full set of apparmor profiles
              # Copyright (C) 2019-2021 Mikhail Morfikov
              # Copyright (C) 2021-2024 Alexandre Pujol <alexandre@pujol.io>
              # SPDX-License-Identifier: GPL-2.0-only

              abi <abi/4.0>,

              include <tunables/global>

              # @{exec_path} = /usr/sbin/whoami
              @{exec_path} = {/run/current-system/sw/{bin,libexec},/{,usr/}{,s}bin}/whoami
              profile whoami /{run/current-system/sw/{bin,libexec},{,usr/}{,s}bin}/whoami flags=(attach_disconnected,complain) {
                include <abstractions/base>
                include <abstractions/consoles>
                include <abstractions/nameservice-strict>

                /{run/current-system/sw/{bin,libexec},{,usr/}{,s}bin}/whoami mr,

                include if exists <local/whoami>
              }

              # vim:syntax=apparmor
            '';
          };
        };
      };
    security.apparmor-d = {
      enable = true;
      statusAll = "complain";
    };
  };
}
