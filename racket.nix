{
  pkgs,
  lib ? pkgs.lib,
  racket ? pkgs.racket,
  racket-minimal ? pkgs.racket-minimal,
  mkDerivation ? pkgs.stdenv.mkDerivation,
  optional ? lib.optional,
  optionalString ? lib.optionalString,
  concatLines ? lib.concatLines,
  flatten ? lib.flatten,
  unique ? lib.lists.unique,
  ...
}:
rec {
  inherit racket racket-minimal;
  # packageInfo :: { name: String, path: ?String }
  # racketPackage :: { src: Path, info: [ packageInfo ], dependencies: [ racketPackage ] }
  # makeRacketEnvPackageCommands :: racketPackage -> [ String ]
  makeRacketEnvPackageCommands =
    {
      src ? ./.,
      infos ? [
        {
          name = "";
        }
      ],
      dependencies ? [ ],
    }:
    let
      cmd =
        info:
        "raco pkg install --installation --jobs $NIX_BUILD_CORES --deps force --no-setup --skip-installed "
        + (optionalString (info.name != "") "--name ${info.name} ")
        + "--copy ${src}"
        + (optionalString (info ? path) "/${info.path}");
    in
    (map (dep: makeRacketEnvPackageCommands dep) dependencies) ++ (map (p: cmd p) infos);

  combineRacketEnvPackageCommands =
    racketPackages:
    concatLines (unique (flatten (map (rkpkg: makeRacketEnvPackageCommands rkpkg) racketPackages)));

  buildRacketEnv =
    {
      name,
      racketPackage ? (racketWithEnvs racket),
      buildInputs ? [ ],
      racketPkgs ? [ ],
      binary ? false,
    }:
    mkDerivation {
      inherit name;
      buildInputs = buildInputs ++ [ racketPackage ];
      runtimeInputs = optional (!binary) racketPackage;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out
        mkdir -p $out/bin
        cd $out
        raco pkg-env .venv
        source .venv/activate.sh
        cp .venv/activate.sh .venv/execute.sh
        sed -i 's|^.*PS1.*$||' .venv/execute.sh
      ''
      + (combineRacketEnvPackageCommands racketPkgs);
    };

  racketWithEnvs =
    let
      raco-pkg-env = fetchGit {
        url = "git@github.com:samdphillips/raco-pkg-env.git";
        ref = "refs/tags/v0.1.3";
        rev = "fa11a88d5056ca7552dbb5e8b19dacfdf793a177";
      };
    in
    racketPackage:
    racketPackage.overrideAttrs (
      final: prev: {
        postInstall = (optionalString (prev ? postInstall) prev.postInstall) + ''
          raco_pkg_install() {
            $out/bin/raco pkg install --copy --deps fail --skip-installed --scope installation "$1"
          }
          raco_pkg_install  "${raco-pkg-env}/raco-pkg-env-lib"
          raco_pkg_install  "${raco-pkg-env}/raco-pkg-env"
        '';
      }
    );
}
