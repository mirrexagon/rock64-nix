{ stdenv, lib, fetchFromGitHub, linuxManualConfig, python, features ? {}, kernelPatches ? [], randstructSeed ? null }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };

  version = "4.4.185-1222-rockchip-ayufan";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-kernel";
    rev = version;
    sha256 = "1981axj09r5zzkck6m5l127j2207pnxrzalhxysb7c8h0kyhdqm3";
  };

  extraOptions = {
    BINFMT_MISC = "y";
  };

  configfile = stdenv.mkDerivation {
    name = "ayufan-rock64-linux-kernel-config-${version}";
    version = version;
    inherit src;

    buildPhase = ''
      make rockchip_linux_defconfig

      cat > arch/arm64/configs/nixos_extra.config <<EOF
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: "CONFIG_${n}=${v}") extraOptions
      )}
      EOF

      make nixos_extra.config
    '';

    installPhase = ''
      cp .config $out
    '';
  };

  drv = linuxManualConfig ({
    inherit stdenv kernelPatches;

    inherit src;

    inherit version;
    modDirVersion = "4.4.185";

    inherit configfile;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  } // lib.optionalAttrs (randstructSeed != null) { inherit randstructSeed; });

in

stdenv.lib.extendDerivation true passthru drv
