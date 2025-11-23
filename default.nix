let
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "117cc7f94e8072499b0a7aa4c52084fa4e11cc9b";
  }) {};
in {
  git-pocket = pkgs.callPackage ./package.nix {};
  formatter = pkgs.callPackage ./format.nix {};
}
