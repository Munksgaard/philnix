{ pkgs, config, ... }:
let
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = ./emacs.el;
    package = pkgs.emacs30-pgtk;
    defaultInitFile = true;
    alwaysEnsure = true;

    # Optionally provide extra packages not in the configuration file.
    # This can also include extra executables to be run by Emacs (linters,
    # language servers, formatters, etc)
    extraEmacsPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
      pkgs.tree-sitter-grammars.tree-sitter-elixir
      pkgs.tree-sitter-grammars.tree-sitter-heex
      pkgs.tree-sitter-grammars.tree-sitter-typescript
      pkgs.tree-sitter-grammars.tree-sitter-tsx
      pkgs.tree-sitter-grammars.tree-sitter-sql
      pkgs.tree-sitter-grammars.tree-sitter-javascript
      pkgs.tree-sitter-grammars.tree-sitter-rust
      pkgs.tree-sitter-grammars.tree-sitter-nix
      pkgs.tree-sitter-grammars.tree-sitter-markdown
      pkgs.tree-sitter-grammars.tree-sitter-make
      pkgs.tree-sitter-grammars.tree-sitter-ledger
      pkgs.tree-sitter-grammars.tree-sitter-just
      pkgs.tree-sitter-grammars.tree-sitter-gleam
    ];
  };
in {

  programs.emacs = {
    enable = true;
    package = emacs;
  };

  services = {
    emacs = {
      enable = true;
      package = emacs;
      defaultEditor = true;
      startWithUserSession = true;
    };
  };
}
