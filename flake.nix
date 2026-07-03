{
  description = "Templates for rapid Nix flake project bootstrapping";

  outputs = { self }: {
    templates = {
      # --- base templates: full projects, run in an empty dir ---

      default = {
        path = ./default;
        description = "Minimal cross-platform dev shell: nix + just + prek, bring your own tech";
      };

      python = {
        path = ./python;
        description = "Python dev shell: python312 + uv, plus the shared just/prek scaffold";
      };

      rust = {
        path = ./rust;
        description = "Rust dev shell: cargo/rustc/clippy/rustfmt/rust-analyzer, plus the shared scaffold";
      };

      godot = {
        path = ./godot;
        description = "Godot dev shell: godotPackages_4_6 + bun, plus the shared scaffold";
      };

      dotnet = {
        path = ./dotnet;
        description = ".NET dev shell: dotnetCorePackages.sdk_10_0, plus the shared scaffold";
      };

      zig = {
        path = ./zig;
        description = "Zig dev shell via mitchellh/zig-overlay, plus the shared scaffold";
      };

      # --- addon templates: single files, run inside an already-inited project ---

      secrets = {
        path = ./secrets;
        description = "Addon: drop-in secretspec.toml (declarative secrets) — see its header for flake.nix wiring notes";
      };

      woodpecker = {
        path = ./woodpecker;
        description = "Addon: drop-in .woodpecker.yml (CI, checks the flake) — no flake.nix changes needed";
      };
    };
  };
}
