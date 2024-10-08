{ lonLib, ... }: {
  imports = [ ./ssh.nix ./sshd.nix ];
  options.lonsdaleite.net = (lonLib.mkEnableFrom [ ] "hardens networking")
    // (lonLib.mkParanoiaFrom [ ] [ ]);
}
