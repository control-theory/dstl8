{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.1.1-test";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "c7dfc6145d0c88a87a39508cd0bf4a1a44aae97e7d8be0e501b6efa76485938f"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "f46612087457a38e2138684bdf8c98025a18fbb585c0f93bd791cc8bc100384c"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "76dfd5467433e78aa1dd93f29acd760a11cfae07c7b95295c167695b4531e916"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "efb3f580c461abce62dc0d4dd5601103a7f5d25cab832685c56e0c426a6d4bac"; };
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
