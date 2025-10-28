{ pkgs, ... }:
let
  fishBin = "${pkgs.fish}/bin/fish";
in {
  programs.fish.enable = true;
  environment.sessionVariables.SHELL = fishBin;
  users.defaultUserShell = pkgs.fish;
}
