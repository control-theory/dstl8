{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.14";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "b9dd45af7a8f1244ee9f1e76c3ba94be00671915c62eec68534e976893fdaa69"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "41d58397937ece880ec9c7a2eb82373671ef8f7a12c8733a716c344d0ae90f0d"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "fdafe0a08794f1a4f9bb7ce3411d3e997cb68bddf07a41dafdac7a8ea38a4337"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "a25c2d559dfacbe812b9683a0d859ee5a0fb9c24e8fabb0a211b9e410b489f2e"; };
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
