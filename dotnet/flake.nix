{
  description = ".NET project dev environment";

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
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            prek
            # SDK major version is pinned by the attr (sdk_10_0). For
            # multi-targeting, combine versions instead of listing one:
            #   pkgs.dotnetCorePackages.combinePackages [ sdk_9_0 sdk_10_0 ]
            # NuGet package versions are pinned in packages.lock.json —
            # commit it and run `dotnet restore --locked-mode` in CI.
            dotnetCorePackages.sdk_10_0
          ];

          shellHook = ''
            echo "${builtins.readFile ./banner.txt}"
            echo " -> $(basename "$PWD")"
            echo ""
            just -l
            echo ""
            echo "Note: native-library interop (e.g. some NuGet packages with"
            echo "native deps) may need programs.nix-ld.enable on NixOS."
          '';
        };
      });

      # No package output by default.
      # packages = forAllSystems (pkgs: {
      #   default = pkgs.buildDotnetModule {
      #     pname = "my-project";
      #     version = "0.1.0";
      #     src = ./.;
      #     projectFile = "MyProject/MyProject.csproj";
      #     nugetDeps = ./deps.json; # generated via `nix build .#default.passthru.fetch-deps`
      #   };
      # });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
