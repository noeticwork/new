{
  description = "Zig project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/<rev-or-tag>";  # pin for reproducibility

    # nixpkgs' own `zig` lags upstream releases, so pin Zig itself via
    # mitchellh/zig-overlay instead of nixpkgs.
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets/CI: addon templates, not inputs — `nix flake init -t <this-repo>#secrets` / `#woodpecker`
  };

  outputs = { nixpkgs, zig-overlay, ... }@inputs:
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
          # Zig ships its own C toolchain (`zig cc`), so mkShellNoCC is
          # sufficient even for C interop.
          buildInputs = [
            pkgs.just
            pkgs.prek
            # `.default` tracks the latest tagged Zig release; `.master` is
            # nightly (updates daily) — pick one deterministically. Either
            # way, update via `nix flake lock --update-input zig-overlay`.
            zig-overlay.packages.${pkgs.system}.default
            # zig-overlay.packages.${pkgs.system}.master
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
      #   default = pkgs.stdenv.mkDerivation {
      #     pname = "my-project";
      #     version = "0.1.0";
      #     src = ./.;
      #     nativeBuildInputs = [ zig-overlay.packages.${pkgs.system}.default ];
      #     buildPhase = "zig build -Doptimize=ReleaseSafe";
      #   };
      # });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
