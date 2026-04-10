{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-33001237923792379"; # DO NOT FORGET TO CHANGE THIS PROPERLY!!!
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f" # Override existing partition
                ];
                subvolumes = {
                  "@root" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                  "@home" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/home";
                  };
                  "@snapshots" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/.snapshots";
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
  fileSystems."/.snapshots".neededForBoot = true;
}