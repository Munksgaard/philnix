{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.emacsConfig;
  combinedConfig = builtins.readFile ./emacs.el + cfg.extraConfig;
  configFile = builtins.toFile "init.el" combinedConfig;
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = configFile;
    package = pkgs.emacs30-pgtk;
    defaultInitFile = true;
    alwaysEnsure = true;

    # Optionally provide extra packages not in the configuration file.
    # This can also include extra executables to be run by Emacs (linters,
    # language servers, formatters, etc)
    extraEmacsPackages = epkgs: [
      (epkgs.trivialBuild {
        pname = "beadwork";
        version = "0.1.0-unstable-2026-05-13";
        src = pkgs.fetchgit {
          url = "https://tangled.org/munksgaard.tngl.sh/beadwork.el";
          rev = "5229266f705086f9fb62ee6c9e37d98af93cf159";
          hash = "sha256-py2ys207NHFVuJaxIrXsdAjqp8jGf3RlITT2RFtwR7M=";
        };
        packageRequires = with epkgs; [
          magit-section
          transient
        ];
      })
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
in
{
  options.emacsConfig = {
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra elisp configuration to append to emacs.el";
    };
  };

  config = {
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
  };
}
