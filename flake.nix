{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.4";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "25639a44861b610689c1061f5cb73b92dc0cba37ca186abeeaf6eda8b9f72f8b"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "63a8c18160952b3455ce4569a18d78dee7e40b923f8c109ef772095b7d16c323"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "022e12644e32093fe46a3102a538dae3d21e1d792081b7070fd2cb5602f4fa94"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "d41cd456d34babb68b348035a5428b11ef5abfb7a2709ee707d149343da4becf"; };
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
