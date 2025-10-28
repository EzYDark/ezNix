{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.cloudflare-warp
  ];

  services.cloudflare-warp = {
    enable = true;
    # Keep the default UDP port open so Warp can actually handshake.
    openFirewall = true;
  };
}
