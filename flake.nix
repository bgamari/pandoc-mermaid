{
  description = "Pandoc mermaid filter";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          pandoc-mermaid-unwrapped = (pkgs.haskellPackages.callCabal2nix "pandoc-mermaid" ./. {}).overrideAttrs (oldAttrs: {
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ pkgs.mermaid-cli ];
          });

          pandoc-mermaid = pkgs.runCommand "pandoc-mermaid-wrapped" {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          } ''
            mkdir -p $out/bin
            makeWrapper ${pandoc-mermaid-unwrapped}/bin/pandoc-mermaid $out/bin/pandoc-mermaid \
              --prefix PATH : "${pkgs.mermaid-cli}/bin"
          '';

          default = pandoc-mermaid;
        };
        apps = rec {
          pandoc-mermaid = flake-utils.lib.mkApp { drv = self.packages.${system}.pandoc-mermaid; };
          default = pandoc-mermaid;
        };
      }
    );
}
