{
  lib,
  writeScriptBin,
  nushell,
}:
writeScriptBin "git-pocket" (let
  shebang = "#!${lib.getExe nushell}";
  script = builtins.readFile ./git-pocket.nu;
in ''
  ${shebang}

  ${script}
'')
