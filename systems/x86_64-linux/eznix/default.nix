{ pkgs, ... }:
let
  modules = ./modules;
in {
  imports = [
    ./hardware-configuration.nix
    ./users_groups.nix
    (modules + "/programs/fish.nix")
    (modules + "/programs/git.nix")
    (modules + "/development/rust.nix")
    (modules + "/development/go.nix")
    (modules + "/development/python.nix")
    (modules + "/development/node.nix")
    (modules + "/development/nix-lang.nix")
    (modules + "/development/ide/cursor.nix")
    (modules + "/services/flatpak.nix")
    (modules + "/services/desktop.nix")
    (modules + "/services/audio.nix")
    (modules + "/services/printing.nix")
    (modules + "/system/boot.nix")
    (modules + "/system/localization.nix")
    (modules + "/system/networking.nix")
  ];

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  networking.hostName = "eznix";

  system.stateVersion = "25.05";
}
