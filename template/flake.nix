{
  description = "Project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pin to a commit/tag instead of a branch for full reproducibility:
    # nixpkgs.url = "github:NixOS/nixpkgs/<rev-or-tag>";

    # Optional second channel, for cherry-picking one package at a version
    # that differs from the primary nixpkgs above (e.g. an older/newer
    # release, or nixpkgs-unstable while the primary tracks stable):
    # nixpkgs-pinned.url = "github:NixOS/nixpkgs/<rev>";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          # mkShellNoCC: no C toolchain by default. Switch to `pkgs.mkShell`
          # the moment you need one (native deps, cc-based build systems).
          buildInputs = with pkgs; [
            just
            # pin your stack here, e.g.:
            # nodejs_22
            # python312
            # go_1_23

            # pulling one package from the separately pinned channel above:
            # (import inputs.nixpkgs-pinned { system = pkgs.system; }).someTool
          ];

          shellHook = ''
            echo "${builtins.readFile ./banner.txt}"
            echo " -> $(basename "$PWD")"
            echo ""
            just -l
            echo ""
          '';
        };
      });

      # `nix fmt` support. nixfmt-tree wraps treefmt so it can format the
      # whole tree (not just single files) without the deprecated
      # directory-passing behavior of the raw formatter package.
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
