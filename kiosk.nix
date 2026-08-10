{ pkgs, ... }:
let
  url = "https://join.gewis.nl";

  browser = pkgs.writeShellScript "kiosk-browser" ''
    exec ${pkgs.chromium}/bin/chromium \
      --kiosk \
      --ozone-platform=wayland \
      --user-data-dir=/tmp/chromium-kiosk \
      --no-first-run \
      --noerrdialogs \
      --disable-infobars \
      --disable-session-crashed-bubble \
      --disable-pinch \
      --check-for-update-interval=31536000 \
      ${url}
  '';
in
{
  users.users.kiosk = {
    isNormalUser = true;
    description = "Kiosk";
    home = "/home/kiosk";
  };

  services.cage = {
    enable = true;
    user = "kiosk";
    program = "${browser}";
  };

  systemd.services.cage-tty1 = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      PrivateTmp = true;
    };
  };
}
