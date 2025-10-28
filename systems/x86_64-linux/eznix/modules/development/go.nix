{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    go
    gopls
  ];

  environment.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };

  systemd.tmpfiles.rules = [
    "d /home/%u/go 0750 %u %u -"
    "d /home/%u/go/bin 0750 %u %u -"
  ];

  programs.fish = lib.mkIf config.programs.fish.enable {
    interactiveShellInit = lib.mkAfter ''
      set -gx GOPATH $HOME/go
      set -gx GOBIN $HOME/go/bin
      fish_add_path -m $GOBIN
    '';
  };
}
