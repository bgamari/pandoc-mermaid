{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          mermaid-filter-unwrapped = (pkgs.haskellPackages.callCabal2nix "mermaid-filter" ./. {}).overrideAttrs (oldAttrs: {
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ pkgs.mermaid-cli ];
          });

          mermaid-filter = pkgs.runCommand "mermaid-filter-wrapped" {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          } ''
            mkdir -p $out/bin
            makeWrapper ${mermaid-filter-unwrapped}/bin/mermaid-filter $out/bin/mermaid-filter \
              --prefix PATH : "${pkgs.mermaid-cli}/bin"
          '';

          default = mermaid-filter;
        };
        apps = rec {
          mermaid-filter = flake-utils.lib.mkApp { drv = self.packages.${system}.mermaid-filter; };
          default = mermaid-filter;
        };
      }
    );
}
