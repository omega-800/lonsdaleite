{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  systemd.services = mkIf cfg.enable {
    # TODO: 
    cups-browsed.serviceConfig = { };
    docker.serviceConfig = { };
    greetd.serviceConfig = { };
    libvirtd.serviceConfig = { };
    mullvad-daemon.serviceConfig = { };
    mysql.serviceConfig = { };
    nix-optimise.serviceConfig = { };
    nscd.serviceConfig = { };
    rtkit-daemon.serviceConfig = { };
    systemd-machined.serviceConfig = { };
    systemd-udevd.serviceConfig = { };
    virtxend.serviceConfig = { };
  };
}
