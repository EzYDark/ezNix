{ pkgs, ... }:
let
  modules = ../../../modules;
in {
  imports = [
    ./hardware-configuration.nix

    (modules + "/system/disko/btrfs.nix")

    ./users_groups.nix
    
    (modules + "/programs/fish.nix")
    (modules + "/programs/git.nix")
    (modules + "/programs/direnv.nix")

    (modules + "/development/rust.nix")
    (modules + "/development/nix-lang.nix")

    (modules + "/services/cloudflare-warp.nix")
    
    (modules + "/system/boot.nix")
    (modules + "/system/localization.nix")
    (modules + "/system/networking.nix")

    (modules + "/system/ssh.nix")
    (modules + "/system/avahi.nix")
  ];

  environment.systemPackages = with pkgs; [
    wget
  ];

  environment.sessionVariables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  hardware.graphics = {
    enable = true;
  };

  programs.nix-ld.enable = true;

  networking.hostName = "ezbox";

  system.stateVersion = "25.11";
}
