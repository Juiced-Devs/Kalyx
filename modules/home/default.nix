{ self, ... }:
{
  imports = builtins.filter
    (f: f != __curPos.file)
    lib.collectModules ./.;
}