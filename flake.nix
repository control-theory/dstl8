{
  description = "dstl8 — CLI and TUI for the dstl8 observability platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        version = "0.2.11";

        pkgs = nixpkgs.legacyPackages.${system};

        # Map Nix system strings to GoReleaser archive naming.
        platformMap = {
          "x86_64-linux"   = { os = "linux";  arch = "amd64"; sha256 = "0721f3ee9904a109fff61c1e27548aa9d7bf78c575742a8c956a06b1e19b85ec"; };
          "aarch64-linux"  = { os = "linux";  arch = "arm64"; sha256 = "6135812671cf40c5267feabee87f017e1fa43b4b40cdb5fcbf32a0a2cbf5a9b0"; };
          "x86_64-darwin"  = { os = "darwin"; arch = "amd64"; sha256 = "602463d824ccee3f6fe2b32f64b782b68db4bba2e472172ed96d4ea993827810"; };
          "aarch64-darwin" = { os = "darwin"; arch = "arm64"; sha256 = "9aad886167684d1d2266d1b9802d6eb7bd71f8f5bba5ad14380a1c31944713f1"; };
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
