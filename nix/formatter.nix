{ inputs, pkgs, ... }:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";

  programs.mdformat.enable = true;
  programs.mdformat.settings.number = true;

  programs.nixfmt.enable = true;
  programs.ruff-format.enable = true;
  programs.yamlfmt.enable = true;
  programs.just.enable = true;
  programs.jsonfmt.enable = true;

  settings = {
    global.excludes = [
      "*.{age,gif,png,svg,env,envrc,gitignore,pickle}"
      ".idea/*"
      ".vscode/*"
      ".python-version"
    ];
  };
}
