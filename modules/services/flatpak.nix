{ ... }:
{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      {
        appId = "io.github.zen_browser.zen";
        origin = "flathub";
      }
      {
        appId = "com.ktechpit.whatsie";
        origin = "flathub";
      }
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    overrides.global.Context.sockets = [ "wayland" "!x11" ];
  };
}
