{
  description = "Rust project dev environment";

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
        # mkShell, not NoCC: linking most crates needs a C toolchain.
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            prek
            # rustc/cargo here track whatever nixpkgs rev is pinned above.
            # Crate versions are pinned in Cargo.lock (`cargo update` to bump).
            # For a rustc version independent of nixpkgs, swap this block for
            # oxalica/rust-overlay or fenix as a flake input instead.
            cargo
            rustc
            rust-analyzer
            clippy
            rustfmt
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
      #   default = pkgs.rustPlatform.buildRustPackage {
      #     pname = "my-project";
      #     version = "0.1.0";
      #     src = ./.;
      #     cargoLock.lockFile = ./Cargo.lock;
      #   };
      # });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
