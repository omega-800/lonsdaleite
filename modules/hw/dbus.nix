# TODO: research https://madaidans-insecurities.github.io/guides/linux-hardening.html\#d-bus
{ pkgs, lib, ... }:
{
  # https://github.com/fort-nix/nix-bitcoin/blob/master/modules/security.nix
  services.dbus.packages = lib.mkAfter [
    # Apply at the end to override the default policy
    (pkgs.writeTextDir "etc/dbus-1/system.d/dbus.conf" ''
      <busconfig>
        <policy context="default">
          <deny
            send_destination="org.freedesktop.systemd1"
            send_interface="org.freedesktop.systemd1.Manager"
            send_member="GetUnitProcesses"
          />
        </policy>
        <policy group="proc">
          <allow
            send_destination="org.freedesktop.systemd1"
            send_interface="org.freedesktop.systemd1.Manager"
            send_member="GetUnitProcesses"
          />
        </policy>
      </busconfig>
    '')
  ];
}
