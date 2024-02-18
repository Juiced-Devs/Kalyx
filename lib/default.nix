lib:
rec {
  readDirPaths = dir: 
    (lib.mapAttrs
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory" then readDirPaths path
        else path) 
      (builtins.readDir dir));
  
  collectFiles = attrs:
    (lib.flatten
      (lib.mapAttrsToList
        (_: v:
          if builtins.isAttrs v then collectFiles v
          else v)
        attrs));
  
  collectModules = dir:
    (builtins.filter
      (f: lib.hasSuffix ".nix" f)
      (collectFiles
        (readDirPaths dir)));
}