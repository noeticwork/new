{
  description = "Python project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/<rev-or-tag>";  # pin for reproducibility

    # Secrets/CI: addon templates, not inputs — `nix flake init -t <this-repo>#secrets` / `#woodpecker`
  };

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
          buildInputs = with pkgs; [
            just
            prek
            # Interpreter version is pinned by the attr name itself (python312).
            # Bump the attr for a new minor version. Dependency versions live
            # in uv.lock — `uv lock --upgrade` to update them deterministically.
            python312
            uv
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

      # No package output by default.
      # packages = forAllSystems (pkgs: {
      #   default = pkgs.python312Packages.buildPythonApplication {
      #     pname = "my-project";
      #     version = "0.1.0";
      #     src = ./.;
      #     pyproject = true;
      #   };
      # });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
