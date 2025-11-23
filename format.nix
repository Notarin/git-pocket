{
  treefmt-nix ?
    import (builtins.fetchGit {
      url = "https://github.com/numtide/treefmt-nix";
      rev = "5b4ee75aeefd1e2d5a1cc43cf6ba65eba75e83e4";
    }),
  lib,
  writeShellScriptBin,
  formats,
  treefmt,
  alejandra,
  callPackage,
}:
treefmt-nix.mkWrapper {inherit lib writeShellScriptBin treefmt formats alejandra;} {
  settings.formatter = {
    nu = let
      topiary-nushell = callPackage (
        {
          lib,
          writeShellApplication,
          topiary-nushell ? fetchGit "https://github.com/blindFS/topiary-nushell",
          tree-sitter-nu ? fetchGit "https://github.com/nushell/tree-sitter-nu",
          topiary,
          nushell,
          writeText,
          callPackage,
        }:
          writeShellApplication (let
            libtree-sitter-nu = callPackage ({
              lib,
              stdenv,
            }:
              stdenv.mkDerivation (finalAttrs: {
                pname = "tree-sitter-nu";
                version = tree-sitter-nu.rev;

                src = tree-sitter-nu;

                makeFlags = [
                  # The PREFIX var isn't picking up from stdenv.
                  "PREFIX=$(out)"
                ];

                meta = with lib; {
                  description = "A tree-sitter grammar for nu-lang, the language of nushell";
                  homepage = "https://github.com/nushell/tree-sitter-nu";
                  license = licenses.mit;
                  platforms = platforms.linux;
                };
              })) {};
          in {
            name = "topiary-nushell";
            runtimeInputs = [nushell topiary];
            runtimeEnv = {
              TOPIARY_CONFIG_FILE = writeText "languages.ncl" ''
                {
                  languages = {
                    nu = {
                      extensions = ["nu"],
                      grammar.source.path = "${libtree-sitter-nu}/lib/libtree-sitter-nu.so",
                    },
                  },
                }
              '';
              TOPIARY_LANGUAGE_DIR = "${topiary-nushell}/languages";
            };
            text = ''
              ${lib.getExe topiary} "$@"
            '';
          })
      ) {};
    in {
      command = "${lib.getExe topiary-nushell}";
      options = ["format"];
      includes = ["*.nu"];
    };
  };
  programs = {
    alejandra = {
      enable = true;
    };
  };
}
