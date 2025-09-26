{
  # TODO: research 
  # NTP is very insecure as it is unauthenticated and unencrypted. 
  # time syncing is important though, so i'll have to look into alternatives
  # sdwdate (Whonix) https://www.whonix.org/wiki/Sdwdate
  # https://gitlab.com/madaidan/secure-time-sync
  services = {
    ntp.enable = false;
    timesyncd.enable = false;
    chrony.enable = false;
  };
}
