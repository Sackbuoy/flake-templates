{
  description = "Random Meme webpage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import package.json to get name and version
        manifest = builtins.fromJSON (builtins.readFile ./package.json);

        bunBuild = pkgs.stdenv.mkDerivation {
          name = manifest.name;
          src = ./.;

          buildInputs = with pkgs; [
            bun
            nodejs
            docker
          ];

          installPhase = ''
            mkdir -p $out/bin $out/app
            cp -r . $out/app/

            cat > $out/bin/${manifest.name} <<EOF
            #!/usr/bin/env bash
            cd $out/app
            export PATH="${pkgs.bun}/bin:${pkgs.nodejs}/bin:$PATH"
            exec ${pkgs.bun}/bin/bun run index.ts
            EOF
            chmod +x $out/bin/${manifest.name}
          '';
        };

        dockerImage = pkgs.dockerTools.buildImage {
          name = "ghcr.io/sackbuoy/${manifest.name}";
          created = "now";
          config = {
            Cmd = ["${pkgs.bash}/bin/bash" "-c" "${bunBuild}/bin/${manifest.name}"];
            ExposedPorts = {
              "3000/tcp" = {};
            };
            WorkingDir = "/app";
          };
          tag = "latest";

          extraCommands = ''
            mkdir -p tmp
            mkdir -p app
            cp -r ${bunBuild}/* app/
          '';

          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [
              pkgs.bash
              pkgs.coreutils
              pkgs.bun
              pkgs.nodejs
            ];
            pathsToLink = ["/bin"];
          };
        };
      in {
        packages = {
          bun = bunBuild;
          docker = dockerImage;
          default = dockerImage;
        };

        # Development shell with necessary tools
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bun
            nodejs
            docker
          ];
        };
      }
    );
}
