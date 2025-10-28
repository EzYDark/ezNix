{
  pkgs,
  ...
}:
{
  users.users = {
    ezy = {
      isNormalUser = true;
      password = "1234";
      group = "ezy";
      extraGroups = [
        "networkmanager"
        "wheel"
        "keyd"
      ];
      shell = pkgs.fish;
    };

    root = { password = "1234"; };
  };

  users.groups = {
    ezy = { members = [ "ezy" ]; };
    keyd = { members = [ "ezy" ]; };
  };
}
