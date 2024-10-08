{ lonLib, ... }: {
  imports = [ ./impermanence.nix ./permissions.nix ./usbguard.nix ];
  options.lonsdaleite.fs = (lonLib.mkEnableFrom [ ] "hardens filesystem")
    // (lonLib.mkParanoiaFrom [ ] [ ]);
}
