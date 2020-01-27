{ nixpkgs ? { outPath = <nixpkgs>; revCount = 56789; shortRev = "gfedcba"; }
, stableBranch ? false
}:

let
  versionSuffix =
    (if stableBranch then "." else "pre") + "${toString nixpkgs.revCount}.${nixpkgs.shortRev}";

  versionModule =
    { system.nixos.versionSuffix = versionSuffix;
      system.nixos.revision = nixpkgs.rev or nixpkgs.shortRev;
    };
in

with (import (nixpkgs+"/nixos/lib/eval-config.nix") {
  modules = [ ./sd-image-rockpro64.nix versionModule ];
});

{
  inherit (config.system.build)
    kernel
    toplevel
    sdImage
    ;
}
