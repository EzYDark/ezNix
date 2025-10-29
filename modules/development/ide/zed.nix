{ pkgs, ... }:
{
  # FHS-wrapped build keeps Zed's bundled tooling from breaking on NixOS
  environment.systemPackages = [
    pkgs.zed-editor-fhs
  ];
}
