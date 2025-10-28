{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python312
    uv
  ];

  environment.sessionVariables = {
    UV_CACHE_DIR = "$HOME/.cache/uv";
  };

  systemd.tmpfiles.rules = [
    "d /home/%u/.cache/uv 0750 %u %u -"
  ];

  programs.fish = lib.mkIf config.programs.fish.enable {
    interactiveShellInit = lib.mkAfter ''
      set -gx UV_CACHE_DIR $HOME/.cache/uv
    '';
  };
}
