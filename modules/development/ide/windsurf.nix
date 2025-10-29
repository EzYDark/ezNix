{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.windsurf.fhs ];
}
