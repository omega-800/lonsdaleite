{ lonLib, ... }: {
  imports = [ ];
  options.lonsdaleite.os = lonLib.mkEnableFrom [ ] "hardens general os components";
}
