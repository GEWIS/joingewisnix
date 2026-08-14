{ config, ... }:
{
  sops.secrets = {
    iotroam-psk = { };
    hotspot-psk = { };
  };

  sops.templates."wpa-secrets" = {
    owner = "wpa_supplicant";
    content = ''
      psk_iotroam=${config.sops.placeholder.iotroam-psk}
    '';
  };

  systemd.services.wpa_supplicant = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
    unitConfig.StartLimitIntervalSec = 0;
  };

  networking.wireless = {
    enable = true;
    secretsFile = config.sops.templates."wpa-secrets".path;
    networks = {
      iotroam = {
        pskRaw = "ext:psk_iotroam";
        priority = 10;
      };
    };
    extraConfig = ''
      mac_addr=0
      preassoc_mac_addr=0
    '';
  };
}
