{
  description = "A simple Python project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        pythonPkgs = pkgs.python311Packages;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pythonPkgs; [
            requests
            pandas
          ];
        };
        # buildInputs = with pkgs; [
        #   python3.withPackages
        #   (ps: [
        #     ps.requests
        #     ps.pandas
        #   ])
        # ];
        # };
      }
    );
}
