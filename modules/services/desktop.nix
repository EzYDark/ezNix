{ ... }:
{
  services.xserver.enable = true;
  services.displayManager = {
    sddm.enable = true;
    autoLogin = {
      enable = true;
      user = "ezy";
    };
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "cz";
    variant = "";
  };
}
