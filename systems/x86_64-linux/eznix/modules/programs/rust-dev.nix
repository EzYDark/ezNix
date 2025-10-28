{ config, lib, pkgs, ... }:
let
  sccacheBin = "${pkgs.sccache}/bin/sccache";
in {
  environment.systemPackages = with pkgs; [
    rustup
    rust-analyzer
    sccache
  ];

  environment.sessionVariables = {
    RUSTC_WRAPPER = sccacheBin;
  };

  programs.fish = lib.mkIf config.programs.fish.enable {
    interactiveShellInit = lib.mkAfter ''
      set -gx SCCACHE_DIR $HOME/.cache/sccache
      set -gx SCCACHE_CACHE_SIZE 10G
      set -gx RUSTC_WRAPPER ${sccacheBin}
    '';
  };

  systemd.tmpfiles.rules = [
    "d /home/%u/.cache/sccache 0700 %u %u -"
  ];
}
