{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.5";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "beb269b1050eda32ea4ea2f65fd3a703100af1e5911b4651cb7dc3a99440b453"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "76da7da6058f98598cfa722301dbb33fcdcfc0dc55e0a2f2e60064736e51bc54"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "b729c915e9de1003c8cff71e26fa2bed7a4b2ff4964dea8cfdc12fac120da02e"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "09898dec82f71802688aea836aa130864b60cad0a7965d97c091e95ba9a8fb91"; };
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
