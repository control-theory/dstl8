{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.8";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "bdbeab8ab29aa2c6f53a76a106206493a1fb1af5ac19fd46e61e1ac7a5777fa8"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "b8eb895ed492f3c552872106eee124aa1a9ab97412daa456992f82eb32da86fc"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "ca366dc41f43d56e9709af0f67ce5f14d247aca0f79159421bd6d54b1edb22d1"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "c6e241d45c9651386c862999a5200c944e34fe2e93f8769428734f8c2d8fc6b4"; };
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
