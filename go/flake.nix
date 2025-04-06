{
  description = "A simple Go development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          gopls
          gotools
          golangci-lint
          delve
        ];

        shellHook = ''
          echo "Go development environment loaded!"
          export GOPATH=$HOME/go
          export PATH=$GOPATH/bin:$PATH
        '';
      };
    });
}
