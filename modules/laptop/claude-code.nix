{
  trivialBuild,
  fetchFromGitHub,
  all-the-icons,
  claude-code,
}:
trivialBuild rec {
  pname = "claude-code";
  version = "main-2025-08-07";
  src = fetchFromGitHub {
    owner = "stevemolitor";
    repo = "claude-code.el";
    rev = "2025ad55257bcfc78eff31f1355ff7b27c6a583f";
    hash = "sha256-OODqQ3yStY7sKIJe2Kdzqoech/av+icsQRRmyLIJ3tU=";
  };
  # elisp dependencies
  propagatedUserEnvPkgs = [
    all-the-icons
    claude-code
  ];
  buildInputs = propagatedUserEnvPkgs;
}
