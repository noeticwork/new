{
  description = "Project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pin to a commit/tag instead of a branch for full reproducibility, and
    # update deliberately with `nix flake lock --update-input nixpkgs`:
    # nixpkgs.url = "github:NixOS/nixpkgs/<rev-or-tag>";
  };

  # Want secrets management or CI wired in? These are addon templates, not
  # inputs — they only drop files, so run them inside an already-inited
  # project: `nix flake init -t <this-repo>#secrets` / `#woodpecker`.

  outputs = { nixpkgs, ... }@inputs:
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
          # the moment you need one.
          buildInputs = with pkgs; [
            just
            prek # drop-in pre-commit, single Rust binary — see .pre-commit-config.yaml
            # pin your stack here, e.g.:
            # nodejs_22
            # python312
            # go_1_23
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

      # No package output by default — this is a dev shell, not a build.
      # Uncomment and adapt once you have something to build:
      # packages = forAllSystems (pkgs: {
      #   default = pkgs.stdenv.mkDerivation {
      #     pname = "my-project";
      #     version = "0.1.0";
      #     src = ./.;
      #   };
      # });

      # `nix fmt` support. nixfmt-tree wraps treefmt so it can format the
      # whole tree, not just single files.
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
