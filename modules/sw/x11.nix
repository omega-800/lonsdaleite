{
  # TODO: research or disable completely in favor of wayland?
  # https://firejail.wordpress.com/documentation-2/x11-guide/
  # https://freedesktop.org/wiki/Software/Xephyr/
  # https://www.xpra.org/
  # Xorg is a massive amount of code and runs as root by default. This makes it more likely to have exploits that can gain root privileges. To stop it from using root create /etc/X11/Xwrapper.config and add
  services.xserver.extraConfig = ''
    needs_root_rights = no 
  '';
}
