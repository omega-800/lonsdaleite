{ lon-lib, ... }: {
  imports = [ ./impermanence.nix ./permissions.nix ./usbguard.nix ];
  options.lonsdaleite.fs = (lon-lib.mkEnableFrom [ ] "hardens filesystem")
    // (lon-lib.mkParanoiaFrom [ ] [ ]);
}
