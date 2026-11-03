{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.12";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "1931742f6e43cfb6de5df4a03427ecd0fb4fd0e3d9692f31d3caeb0a8a0bd431"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "24fe3c2212fe334ac1466c40687238db705820c8114cfbf5e648fc38bb9b4f89"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "b8836c907a8e0dc1f631670a270db791dbf556cc4853c98548e26a70900f26c6"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "e276ad16c76b6f713e37a5606c9e1ecbdfab53684017f7e845162834a450c3c6"; };
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
