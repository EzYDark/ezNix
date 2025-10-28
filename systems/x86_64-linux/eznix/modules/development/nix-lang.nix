{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
  ];

  programs.fish = lib.mkIf config.programs.fish.enable {
    interactiveShellInit = lib.mkAfter ''
      set -gx NIX_CONFIG "experimental-features = nix-command flakes"
    '';
  };
}
