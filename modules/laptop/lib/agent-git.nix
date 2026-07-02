{ lib, pkgs }:

let
  unsignedGitSettings = [
    {
      key = "commit.gpgSign";
      value = "false";
    }
    {
      key = "rebase.gpgSign";
      value = "false";
    }
    {
      key = "tag.gpgSign";
      value = "false";
    }
  ];

  gitConfigCommands = lib.concatMapStringsSep "\n" (
    { key, value }: "add_git_config ${lib.escapeShellArg key} ${lib.escapeShellArg value}"
  ) unsignedGitSettings;
in
let
  wrapExecutableWithUnsignedGit =
    name: executable:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        add_git_config() {
          local index="''${GIT_CONFIG_COUNT:-0}"
          export "GIT_CONFIG_KEY_$index=$1"
          export "GIT_CONFIG_VALUE_$index=$2"
          export GIT_CONFIG_COUNT=$((index + 1))
        }

        ${gitConfigCommands}

        exec ${lib.escapeShellArg executable} "$@"
      '';
    };
in
{
  wrapWithUnsignedGit =
    package: program: wrapExecutableWithUnsignedGit program "${lib.getBin package}/bin/${program}";

  wrapMainProgramWithUnsignedGit =
    package: wrapExecutableWithUnsignedGit package.meta.mainProgram (lib.getExe package);
}
