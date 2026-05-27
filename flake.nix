{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.3";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "eb59e9d5e5a9f5c69d2a5f24272f69c504be0efd245492980549fac7f722b6c5"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "52af8883b21c2126dee950245b6b16cc5294730584c5a04b310c5e9889cc17c4"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "eb6000019a3f02374a9ae3c820ec61c520e78165b48c688e86ab5a2a47383f4a"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "f8176e9aceb283bc64c43be5baaa4c4cf8efd478d9e528797fc678c25905295f"; };
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
