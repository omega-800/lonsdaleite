{ lonLib, ... }: {
  imports = [ ];
  options.lonsdaleite.net = lonLib.mkEnableFrom [ ] "hardens networking";
}
