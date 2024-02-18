self:
{
  imports = builtins.filter
    (f: f != __curPos.file)
    (self.lib.collectModules ./.);
}