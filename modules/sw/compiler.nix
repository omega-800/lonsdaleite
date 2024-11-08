{ pkgs, ... }:
{
  # nixpkgs/doc/stdenv/stdenv.chapter.md
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html#hardened-compilation-flags
  nixpkgs.hostPlatform = {
    # https://blog.mayflower.de/5800-Hardening-Compiler-Flags-for-NixOS.html
    # 
    # https://github.com/NixOS/nixpkgs/pull/12895
    # https://hydra.mayflower.de/

    # https://madaidans-insecurities.github.io/guides/linux-hardening.html#hardened-compilation-flags
    #TODO: -flto -fvisibility=hidden -fsanitize=cfi -fsanitize=shadow-call-stack -fsanitize=safe-stack -fsanitize=signed-integer-overflow,unsigned-integer-overflow -fsanitize-trap=signed-integer-overflow,unsigned-integer-overflow -fstack-clash-protection

    # gcc: -ftrivial-auto-var-init=zero 
    # clang: -ftrivial-auto-var-init=zero -enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang

    inherit (pkgs) system;
    # TODO: use musl instead of glibc
    # https://cyberchaos.dev/cyberchaoscreatures/musl-nixos/-/blob/main/nixos-fixes.nix?ref_type=heads
    # https://github.com/NixOS/nixpkgs/issues/90147
    # pkgs.lib.systems.examples.musl64
    config = "x86_64-unknown-linux-musl";
    # TODO: or clang? https://nixos.wiki/wiki/Using_Clang_instead_of_GCC
    # overlay?
    # final: prev: { inherit (prev.pkgsMusl) /*...*/; }
    # maybe?
    # nixosSystem { modules = [ ... ({ config, ... }: { _module.args.pkgs = (import <nixpkgs> { /* inherit (config.nixpkgs) config overlays;*/ }).pkgsMusl; }) ]; }

  };

  environment.variables.LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";

}
