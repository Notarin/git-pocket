{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux"];
    buildEachSystem = output: builtins.map output systems;
    buildAllSystems = output: (
      builtins.foldl' nixpkgs.lib.recursiveUpdate {} (buildEachSystem output)
    );
  in
    buildAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages.${system} = {
        git-pocket = pkgs.callPackage ./package.nix {};
        default = self.packages.x86_64-linux.git-pocket;
      };
      formatter.${system} = pkgs.callPackage ./format.nix {};
    });
}
