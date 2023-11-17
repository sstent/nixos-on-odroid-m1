# NixOS on ODROID-M1

(based on https://github.com/povik/nixos-on-odroid-n2 and hellabyte's work here https://discourse.nixos.org/t/newbie-installs-nixos-on-an-arm-sbc-or-how-patience-is-a-virtue/35020)

These are configuration files which make it easier to set up and maintain a NixOS installation on an ODROID-M1 single-board computer.

The system is set up to be loaded through Petitboot.

Kernel is mainline.

Patches are welcome!

## Building an initial SD/MMC image

On an aarch64 system (or with aarch64 emulation):

`nix build .#images.m1`

On an aarch64 system:

`nix build --option system aarch64-linux --option sandbox false .#images.m1`

