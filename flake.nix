{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.1";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "e3bb15662310aff883acdf84075088ab502a179f31253d5e531e63163e2884a7"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "de3fbe95d144f54eb71c64c827470bce5cd32195742eb137760c8401d45df8b4"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "783e0c98f6b50e2485905a0c7b6e5a034baa1d5079d93ab35ccb04c9551f6c3f"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "c21ff0749d25be48128d14c2b22db09c6a868b26b1e49e04b90d66724abfe323"; };
        };

        platform = platformMap.${system};

        src = pkgs.fetchurl {
          url = "https://github.com/control-theory/dstl8/releases/download/v${version}/dstl8_${version}_${platform.os}_${platform.arch}.tar.gz";
          sha256 = platform.sha256;
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "dstl8";
          inherit version src;

          sourceRoot = ".";

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            install -Dm755 dstl8 $out/bin/dstl8
          '';

          meta = with pkgs.lib; {
            description = "CLI and TUI for the dstl8 observability platform";
            homepage = "https://dstl8.ai";
            platforms = [ system ];
            mainProgram = "dstl8";
          };
        };
      }
    );
}
