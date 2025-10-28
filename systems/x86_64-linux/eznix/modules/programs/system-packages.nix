{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    code-cursor-fhs
    nil
    pnpm
    nodejs
    python312
    uv
    alacritty
    rustup
    rust-analyzer
    go
  ];
}
