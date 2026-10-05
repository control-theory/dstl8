{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.10";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "d348ab4d6b6f01038a24d85066ab3863b6ccaca39b0e5b7f592b9d9d0d69b4b1"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "8a9d3d5a0bb4bda0051feb3f6b192d3ab7d9c216333e1df1d281919fb1e379bc"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "97b6d1d04847b91d27c12b96cdeb38102d38c3274512b20a33cb506b4957825e"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "95b8564690265ca517eb18a20d537bdfea14c6f22fa827851fa4646ef10412db"; };
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
