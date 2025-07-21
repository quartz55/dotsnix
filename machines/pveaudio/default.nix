{
  inputs,
  config,
  lib,
  pkgs,
  nixosModules,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/proxmox-lxc.nix"
    nixosModules.proxmox
    inputs.musnix.nixosModules.musnix
  ];

  environment.systemPackages = with pkgs; [
    vim
    bat
    kakoune
    bluez
    bluez-tools
    usbutils
    alsa-utils
    busybox
  ];
  time.timeZone = "Europe/Lisbon";
  system.stateVersion = "24.05";

  proxmox.enable = true;
  # musnix.enable = true;
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings.Policy.AutoEnable = "true";
    settings.General = {
      Enable = "Source,Sink,Media,Socket";
      Name = "discopotty";
    };
  };
  services.blueman.enable = true;

  services.openssh.settings.UsePAM = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    raopOpenFirewall = true;
    # Socket activation too slow for headless; start at boot instead.
    socketActivation = false;
    systemWide = true;
    wireplumber.extraConfig.headless = {
      "support.dbus" = false;
      "support.logind" = false;
      "monitor.bluez.seat-monitoring" = false;
    };
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };
  # Start WirePlumber (with PipeWire) at boot.
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  proxmox.mappedGroups = [
    {
      id = 503;
      name = "nas";
    }
  ];
  users.users.root.extraGroups = [
    "nas"
    "audio"
  ];

  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = [ "bind" ];
  };
}
