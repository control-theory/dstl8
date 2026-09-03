{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.9";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "d1394b862adef903d15b1ebabdb6ec8a549f3fa7257c57687e571ff1416af9f5"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "bbac86511d7612499a99c608f6f40a3b1c5bee23a9b517cfc4482fd7d58fb3b8"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "523aaf07cb39c5ad2cc647e74886e86f4857d3cfe70846c4f5d7c32702d47179"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "8297348271382b4aa20e91ca978a284a9c3a39d3d5f4b05e9ef2ac84ea1f8331"; };
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
