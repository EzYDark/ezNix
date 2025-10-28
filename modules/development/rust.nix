{ pkgs, ... }:
let
  sccacheBin = "${pkgs.sccache}/bin/sccache";
in {
  environment.systemPackages = with pkgs; [
    rustup
    rust-analyzer
    sccache
  ];

  environment.sessionVariables.RUSTC_WRAPPER = sccacheBin;
}
