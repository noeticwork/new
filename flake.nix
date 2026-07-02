{
  description = "Templates for rapid Nix flake project bootstrapping";

  outputs = { self }: {
    templates = {
      default = {
        path = ./template;
        description = "Minimal cross-platform dev shell: nix + just, bring your own tech";
        welcomeText = ''
          Minimal Nix + Just scaffold initialized.

          - `direnv allow` (or `nix develop`) to enter the shell
          - bare `just` lists recipes (currently all commented stubs)
          - pin your toolchain in `flake.nix` under `buildInputs`
          - edit `banner.txt` to reskin the shell banner
        '';
      };
    };
  };
}
