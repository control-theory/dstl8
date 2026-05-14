{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.2";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "1f46709e185a5b206251949481d3b8c254c085a24a0943458a67f510e670dc69"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "7db199a2d0bc697e8f5e47b9053713252a581bc5877a2b070dfbfa017fe479e7"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "b21599d1388d2166a62a40c72f625f516e81ce14b662c885878fda8f3b6deba8"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "4289c4d387f9d87aeaab9d3afbb4696d72dbd0ed30d37457e5c9b4e90d42a747"; };
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
