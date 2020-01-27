# To build, use:
# nix-build nixos -I nixos-config=sd-image-rock64.nix -A config.system.build.sdImage
{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      inherit pkgs;
    };

  bootConfig = pkgs.runCommand "boot-config" {} ''
    ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d $out/boot
  '';

in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    ./sd-image-rockchip.nix
    ./modules/rockpro64-configuration.nix
    ./modules/packages.nix
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "aarch64-linux";
    message = "sd-image-aarch64.nix can be only built natively on Aarch64 / ARM64; " +
      "it cannot be cross compiled";
  };

  boot.kernelPackages = pkgs.rock64.linuxPackages_ayufan_4_4;

  # Like nixos/modules/profiles/base.nix, but without zfs, because it
  # doesn't build against our funky kernel.
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  sdImage.bootloader = pkgs.ubootRockPro64;
  sdImage.storePaths = [ config.system.build.toplevel ];
  sdImage.installPaths = [ bootConfig ];
}
