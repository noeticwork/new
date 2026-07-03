{
  description = "Godot project dev environment";

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
          # Swap to `pkgs.mkShell` if you add GDExtension / native modules
          # that need a C or C++ toolchain.
          buildInputs = with pkgs; [
            just
            prek
            # Godot's version is baked into the attr name itself. Bump to
            # godotPackages_4_7 etc. when available, or pin the nixpkgs
            # input above to freeze the exact patch version deterministically.
            godotPackages_4_6.godot
            bun # for `vite` serving exported HTML5 builds
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

      # No package output by default — Godot exports are project-specific.
      # A `just export` recipe calling `godot --export-release <preset> <path>`
      # is usually more practical than a Nix package output here; see the
      # justfile for the build/run stubs to adapt.

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
