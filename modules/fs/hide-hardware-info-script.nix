# https://raw.githubusercontent.com/Kicksecure/security-misc/71c58442ca6d57cd95b72a76ed87f8c248cdbd98/usr/libexec/security-misc/hide-hardware-info
{ pkgs, ... }:
let
  chgrp = "${pkgs.toybox}/bin/chgrp";
  chmod = "${pkgs.toybox}/bin/chmod";
  grep = "${pkgs.toybox}/bin/grep";
  bash = "${pkgs.bash}/bin/bash";
in
pkgs.writeShellScriptBin "hide-hardware-info" # bash
  ''
    ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
    ## See the file COPYING for copying conditions.

    set -o errexit
    set -o nounset
    set -o errtrace
    set -o pipefail
    shopt -s nullglob

    run_cmd() {
      echo "INFO: normal executing   : $@"
      "$@"
    }

    run_cmd_whitelist() {
      echo "INFO: whitelist executing: $@"
      "$@"
    }

    echo "$0: INFO: START"

    default_variables_set() {
      sysfs_whitelist=1
      cpuinfo_whitelist=1
      sysfs=1
      ## https://www.kicksecure.com/wiki/Security-misc#selinux
      selinux=0
    }

    parse_configuration() {
      ## Allows for disabling the whitelist.
      local i
      for i in /usr/local/etc/hide-hardware-info.d/*.conf /etc/hide-hardware-info.d/*.conf ; do
        ${bash} -n "''${i}"
        source "''${i}"
      done
    }

    create_whitelist() {
      if [ "''${1}" = "sysfs" ]; then
        whitelist_path="/sys"
      elif [ "''${1}" = "cpuinfo" ]; then
        whitelist_path="/proc/cpuinfo"
      else
        echo "ERROR: ''${1} is not a correct parameter."
        exit 1
      fi

      if ${grep} -q "''${1}" /etc/group; then
        ## Changing the permissions of /sys recursively
        ## causes errors as the permissions of /sys/kernel/debug
        ## and /sys/fs/cgroup cannot be changed.
        run_cmd_whitelist ${chgrp} --quiet --recursive "''${1}" "''${whitelist_path}" || true

        run_cmd_whitelist ${chmod} o-rwx "''${whitelist_path}"
      else
        echo "ERROR: The ''${1} group does not exist, the ''${1} whitelist was not created."
      fi
    }

    default_variables_set
    parse_configuration

    ## sysfs and debugfs expose a lot of information
    ## that should not be accessible by an unprivileged
    ## user which includes hardware info, debug info and
    ## more. This restricts /sys, /proc/cpuinfo, /proc/bus
    ## and /proc/scsi to the root user only. This hides
    ## many hardware identifiers from ordinary users
    ## and increases security.
    for i in /proc/cpuinfo /proc/bus /proc/scsi /sys ; do
      if [ -e "''${i}" ]; then
        if [ "''${i}" = "/sys" ]; then
          if [ "''${sysfs}" = "1" ]; then
            ## Whitelist for /sys.
            if [ "''${sysfs_whitelist}" = "1" ]; then
              create_whitelist sysfs
            else
              echo "INFO: The sysfs whitelist is not enabled. Some things may not work properly. Full sysfs hardening..."
              run_cmd ${chmod} og-rwx /sys
            fi
          fi
        elif [ "''${i}" = "/proc/cpuinfo" ]; then
          if [ "''${cpuinfo_whitelist}" = "1" ]; then
            create_whitelist cpuinfo
          else
            echo "INFO: The cpuinfo whitelist is not enabled. Some things may not work properly. Full cpuinfo hardening..."
            run_cmd ${chmod} og-rwx /proc/cpuinfo
          fi
        else
          run_cmd ${chmod} og-rwx "''${i}"
        fi
      else
        ## /proc/scsi doesn't exist on Debian so errors
        ## are expected here.
        if ! [ "''${i}" = "/proc/scsi" ]; then
          echo "ERROR: ''${i} could not be found."
        fi
      fi
    done


    if [ "''${sysfs}" = "1" ]; then
      ## restrict permissions on everything but
      ## what is needed
      for i in /sys/* /sys/fs/* ; do
        ## Using '|| true':
        ## https://github.com/Kicksecure/security-misc/pull/108
        if [ "''${sysfs_whitelist}" = "1" ]; then
          run_cmd ${chmod} o-rwx "''${i}" || true
        else
          run_cmd ${chmod} og-rwx "''${i}" || true
        fi
      done

      ## polkit needs stat access to /sys/fs/cgroup
      ## to function properly
      run_cmd ${chmod} o+rx /sys /sys/fs

      ## on SELinux systems, at least /sys/fs/selinux
      ## must be visible to unprivileged users, else
      ## SELinux userspace utilities will not function
      ## properly
      if [ -d /sys/fs/selinux ]; then
        echo "INFO: SELinux detected because folder /sys/fs/selinux exists. See also:"
        echo "https://www.kicksecure.com/wiki/Security-misc#selinux"
        if [ "''${selinux}" = "1" ]; then
          run_cmd ${chmod} o+rx /sys /sys/fs /sys/fs/selinux
          echo "INFO: SELinux mode enabled. Restrictions loosened slightly in order to allow userspace utilities to function."
        else
          echo "INFO: SELinux detected, but SELinux mode is not enabled. Some userspace utilities may not work properly."
        fi
      fi
    fi

    echo "$0: INFO: END"
  ''
