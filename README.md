# An _experimental_ NixOS module to harden your system

Include this in your `flake.nix`:

```nix
lonsdaleite.url = "github:omega-800/lonsdaleite";
```

Then, in your `configuration.nix`, add:

```nix
config.lonsdaleite = {
    enable = true;
    # 0 is for noobies, 1 is moderate and 2 is hardcore
    paranoia = 1;
    # must be normalUser
    trustedUser = "username";
};
```

Now sit back and watch your system be hardened so hard that you won't be even able to access it yourself.
