{ fetchFromGitHub
, buildLinux
, lib
, ...
}@args:
buildLinux (
  args
  // rec {
    version = "6.12.0-rc5";
    modDirVersion = version;

    src = fetchFromGitHub {
      owner = "edera-dev";
      repo = "linux-openpax";
      rev = "7b10d6529a06a2709bdeecbcbd3fd800ff8c4d3e";
      hash = "sha256-+fFu8J9iUt7pnTwz53H+RfWWoi/Ekxx2kmqy9eqVOFk=";
    };
    kernelPatches = [ ];

    # because unset doesn't work?
    ignoreConfigErrors = true;
    inherit extraStructuredConfig;
    # extraConfig = "";
    # extraStructuredConfig = lib.mkForce {
    #   MODULE_COMPRESS_XZ = lib.mkForce lib.kernel.unset;
    #   ZRAM_DEF_COMP_ZSTD = lib.mkForce lib.kernel.unset;
    # };

    extraMeta.branch = "6.12";
  }
    // (args.argsOverride or { })
)
