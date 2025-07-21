{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.nfs.timemachine;
  dirname = "timemachine";
  path = "/mnt/shares/${dirname}";
in
{
  meta.maintainers = [ maintainers.quartz55 ];

  options.nfs.timemachine = {
    enable = mkEnableOption ''
      TimeMachine compatible SAMBA NFS
    '';
  };

  config = mkIf cfg.enable {
    users = {
      groups.timemachine = { };
      users.timemachine = {
        isNormalUser = true;
        description = "Residence of our TimeMachine Samba user";
        group = "timemachine";
        # home = "/var/empty";
        # createHome = false;
        shell = pkgs.shadow;
      };
    };
    users.users.root.extraGroups = [ "timemachine" ];

    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      nssmdns4 = true;
      openFirewall = true;
      # extraServiceFiles = {
      #   smb = ''
      #       <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      #       <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      #       <service-group>
      #       <name replace-wildcards="yes">%h</name>
      #       <service>
      #         <type>_adisk._tcp</type>
      #         <txt-record>sys=waMa=0,adVF=0x100</txt-record>
      #         <txt-record>dk0=adVN=Time Capsule,adVF=0x82</txt-record>
      #       </service>
      #       <service>
      #         <type>_smb._tcp</type>
      #         <port>445</port>
      #       </service>
      #       </service-group>
      #       '';
      # };
    };
    # Note: when adding user do not forget to run `smbpasswd -a <USER>`.
    services.samba = {
      enable = true;
      package = pkgs.samba4Full;
      openFirewall = true;
      securityType = "user";
      extraConfig = ''
        log level = 3
        workgroup = WORKGROUP
        server role = standalone server
        dns proxy = no
        vfs objects = catia fruit streams_xattr

        pam password change = yes
        map to guest = bad user
        usershare allow guests = yes
        create mask = 0664
        force create mode = 0664
        directory mask = 0775
        force directory mode = 0775
        follow symlinks = yes
        load printers = no
        printing = bsd
        printcap name = /dev/null
        disable spoolss = yes
        strict locking = no
        aio read size = 0
        aio write size = 0
        vfs objects = acl_xattr catia fruit streams_xattr
        inherit permissions = yes

        # Security
        server smb encrypt = required
        # client max protocol = SMB3
        # client min protocol = SMB2_10
        # server max protocol = SMB3
        server min protocol = SMB3_00

        # Time Machine
        fruit:delete_empty_adfiles = yes
        fruit:time machine = yes
        fruit:veto_appledouble = no
        fruit:wipe_intentionally_left_blank_rfork = yes
        fruit:posix_rename = yes
        fruit:metadata = stream
      '';

      shares = {
        timemachine = {
          path = dirname;
          public = "no";
          writeable = "yes";
          "valid users" = "timemachine";
          "force user" = "timemachine";
          "force group" = "timemachine";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
      };
    };
    systemd.tmpfiles.rules = [ "d ${dirname} 0770 timemachine timemachine - -" ];
  };
}
