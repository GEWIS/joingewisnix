{ ... }:
{
  imports = [
    ./disko.nix
    ./kiosk.nix
    ./wifi.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "consoleblank=0" ];
    initrd.availableKernelModules = [
      "ahci"
      "nvme"
      "sd_mod"
      "sr_mod"
      "usbhid"
      "usb_storage"
      "virtio_blk"
      "virtio_pci"
      "xhci_pci"
    ];
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "joingewis";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/sops/key";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  system.stateVersion = "26.05";
}
