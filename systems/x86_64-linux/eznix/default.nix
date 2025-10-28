{ ... }:
let
  modules = ./modules;
in {
  imports = [
    ./hardware-configuration.nix
    ./users_groups.nix
    (modules + "/programs/system-packages.nix")
    (modules + "/programs/fish.nix")
    (modules + "/programs/rust-dev.nix")
    (modules + "/programs/git.nix")
    (modules + "/services/flatpak.nix")
    (modules + "/services/desktop.nix")
    (modules + "/services/audio.nix")
    (modules + "/services/printing.nix")
    (modules + "/system/boot.nix")
    (modules + "/system/localization.nix")
    (modules + "/system/networking.nix")
  ];

  networking.hostName = "eznix";

  system.stateVersion = "25.05";
}
