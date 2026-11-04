{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.13";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "b0d177069414ec6ac56badf74fd1ac4b70b82eb05b4d4fa61e8bfdf4935a6f70"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "5e4620b639ae18b7b8bcd08d8a8da9b72e20da743ef6d6f0f69bcfd9cbdd7e61"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "1aaf870f390b641c44817dd3411a0f0af41426c21f6d9ecbcbd3ff4992c0becd"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "43094ac4ca99baf495e60f8cf7e783c503471e9821187afd3f99d8bacb799d62"; };
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
