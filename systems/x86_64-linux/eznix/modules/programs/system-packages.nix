{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    code-cursor-fhs
    alacritty
  ];
}
