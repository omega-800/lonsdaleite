{
  lon-lib,
  lib,
  config,
  ...
}:
let
  cfg = config.lonsdaleite.sw.x11;
  inherit (lib) mkIf;
  inherit (lon-lib)
    mkEnableFrom
    ;
in
{
  options.lonsdaleite.sw.x11 = mkEnableFrom [ "sw" ] "Hardens x11";
  # TODO: research or disable completely in favor of wayland?
  # https://firejail.wordpress.com/documentation-2/x11-guide/
  # https://freedesktop.org/wiki/Software/Xephyr/
  # https://www.xpra.org/
  # Xorg is a massive amount of code and runs as root by default. This makes it more likely to have exploits that can gain root privileges. To stop it from using root create /etc/X11/Xwrapper.config and add
  config = mkIf cfg.enable {
    services.xserver.extraConfig = ''
      needs_root_rights = no 
    '';
  };
}
