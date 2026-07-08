{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.6";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "1b80d68dca44b749bfeea310c35949c0d1c21ee5bb5ad307770b535caf81413e"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "35fdf69658ea0248ab9bde4640aa809ba9d5d0c76773ef7ee10228a2ba57fd20"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "5632ffb2b7bfb6e611286d4faab4fe5a794c3a70f486c20de0175f35d1aba4bc"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "ee793d1d7dfda5b02afe4994b4edde92dcd458f2d47044dafba9b1778110011d"; };
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
