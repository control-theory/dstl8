{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.7";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "ecf25c5ce86356e09ccbd0972e36bedc4cd2ceaba555dc8ca0e613c5c3176c2c"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "41b0a728f6efbe29a0a4907752a43de012301da57b407434cc75fdcdd74f9e9f"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "5341dd62ff224a69700d998bfd95932ccc8e5fdf8b5175398fbcf1966bb0c1df"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "57fcb4bb3257a90ce4003fc281210d8ca324f4ec60ba88927c974f4e964a8748"; };
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
