{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    pnpm
  ];

  environment.sessionVariables.PNPM_HOME = "$HOME/.local/share/pnpm";

  systemd.tmpfiles.rules = [
    "d /home/%u/.local/share/pnpm 0750 %u %u -"
  ];

  programs.fish = lib.mkIf config.programs.fish.enable {
    interactiveShellInit = lib.mkAfter ''
      set -gx PNPM_HOME $HOME/.local/share/pnpm
      fish_add_path -m $PNPM_HOME
    '';
  };
}
