# racket-flake
might not actually work. \
quick and dirty for building a racket environment using [raco-pkg-env](https://pkgs.racket-lang.org/package/raco-pkg-env). \
made it because racket2nix wasn't working for me. \
mostly done so that I could get racket-langserver working. \
first run will do a full compilation of racket because it works by overriding pkgs.racket.

## dependency resolution
no dependency resolution.
instead you have to manually add all dependencies, which use the following format:
```nix
package-format = {
  src = fetcherName {...};
  infos = [
    {
      name = "package-name";
      path = "subdirectory of src" or "" (optional);
    }
    {
      name = "package-name2";
      path = "subdirectory2 of src" or "" (optional);
    }
  ];
  dependencies = [ dep1 dep2 ]
}
```
this means that collections are also manual.
See packages.nix for simple examples.
