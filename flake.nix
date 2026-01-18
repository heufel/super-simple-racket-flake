{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      setupSystem = eachSystem (system: rec {
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        inherit (import ./racket.nix { inherit pkgs; })
          racket
          racket-minimal
          racketWithEnvs
          buildRacketEnv
          ;
      });
    in
    {
      builders = eachSystem (
        system: with setupSystem.${system}; {
          inherit racketWithEnvs buildRacketEnv;
        }
      );
      packages = eachSystem (
        system:
        with setupSystem.${system};
        with (import ./packages.nix { inherit pkgs; });
        rec {
          racket-with-envs = racketWithEnvs pkgs.racket;
          racket-langserver-env = buildRacketEnv {
            racketPackage = [ racket-with-envs ];
            name = "racket-langserver-env";
            racketPkgs = [ racket-langserver ];
          };
          racket-langserver-bin = pkgs.writeShellApplication {
            name = "racket-langserver";
            runtimeInputs = [ racket-langserver-env ];
            text = ''
              # shellcheck disable=SC1091
              source ${racket-langserver-env}/.venv/execute.sh
              racket -l racket-langserver
            '';
          };
        }
      );
      devShells = eachSystem (
        system:
        with setupSystem.${system};
        let
          selfPackages = self.outputs.packages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              selfPackages.racket-with-envs
              selfPackages.racket-langserver-env
            ];
            shellHook = ''
              source ${selfPackages.racket-langserver-env}/.venv/activate.sh
            '';
          };
        }
      );
    };
}
