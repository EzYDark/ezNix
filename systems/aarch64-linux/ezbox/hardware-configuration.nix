{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [
    "nvme"                        # M.2 NVMe SSDs
    "xhci_pci"                    # USB 3.0
    "usb_storage"                 # USB Mass Storage
    "usbhid"                      # USB Input devices
    "phy_rockchip_naneng_combphy" # PCIe/SATA/USB3 PHY
    "phy_rockchip_snps_pcie3"     # PCIe 3.0 PHY
    "phy_rockchip_inno_usb2"      # USB 2.0 PHY
    "phy_rockchip_typec"          # Type-C PHY
    "mmc_block"                   # SD/eMMC block driver
    "dw_mmc_rockchip"             # Rockchip legacy SD/eMMC
    "sdhci_of_dwcmshc"            # Rockchip SDHCI
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "rk808"      # Power management IC
    "panfrost"   # Mali GPU driver

    "libcomposite"
  ];
  boot.extraModulePackages = [ ];

  hardware = {
    deviceTree = {
      # https://github.com/armbian/linux-rockchip/tree/rk-6.1-rkr5.1/arch/arm64/boot/dts/rockchip
      # https://github.com/radxa-pkg/radxa-overlays/tree/main/arch/arm64/boot/dts/rockchip/overlays
      name = "rockchip/rk3588-rock-5b.dtb";
      enable = true;
      overlays = [
      {
        name = "rk3588-dwc3-peripheral";
        dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              metadata {
                title = "Set OTG port 0 to Peripheral mode";
                compatible = "radxa,rock-5a", "radxa,rock-5b", "radxa,rock-5c", "radxa,rock-5d", "radxa,cm5-io", "radxa,nx5-io", "radxa,e52c";
                category = "misc";
                exclusive = "usbdrd_dwc3-dr_mode";
                description = "Set OTG port 0 to Peripheral mode.
            Use this when you want to connect to another computer.";
              };
            };

            &usbdrd_dwc3_0 {
              status = "okay";
              dr_mode = "peripheral";
            };
          '';
        }
      ];
    };

    firmware = [];

    enableRedistributableFirmware = lib.mkForce true;
    enableAllFirmware = lib.mkForce true;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  systemd.services.usb-gadget = {
    description = "Configure USB OTG Gadget";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    
    script = ''
      CONFIGFS="/sys/kernel/config/usb_gadget/rock5b"
      
      # PROPER TEARDOWN SEQUENCE
      # ConfigFS requires strict reverse-order destruction.
      if [ -d "$CONFIGFS" ]; then
        # 1. Unbind from the controller (if currently bound)
        echo "" > $CONFIGFS/UDC 2>/dev/null || true
        
        # 2. Unlink functions from configurations
        rm -f $CONFIGFS/configs/c.1/acm.usb0 2>/dev/null || true
        rm -f $CONFIGFS/configs/c.1/ecm.usb0 2>/dev/null || true
        
        # 3. Remove configuration strings
        rmdir $CONFIGFS/configs/c.1/strings/0x409 2>/dev/null || true
        
        # 4. Remove configurations
        rmdir $CONFIGFS/configs/c.1 2>/dev/null || true
        
        # 5. Remove functions
        rmdir $CONFIGFS/functions/acm.usb0 2>/dev/null || true
        rmdir $CONFIGFS/functions/ecm.usb0 2>/dev/null || true
        
        # 6. Remove gadget strings
        rmdir $CONFIGFS/strings/0x409 2>/dev/null || true
        
        # 7. Remove the gadget itself
        rmdir $CONFIGFS 2>/dev/null || true
      fi

      # INITIALIZATION SEQUENCE
      mkdir -p $CONFIGFS
      cd $CONFIGFS
      
      echo 0x1d6b > idVendor
      echo 0x0104 > idProduct
      echo 0x0100 > bcdDevice
      echo 0x0200 > bcdUSB
      echo 0xEF > bDeviceClass
      echo 0x02 > bDeviceSubClass
      echo 0x01 > bDeviceProtocol
      
      mkdir -p strings/0x409
      echo "0123456789ABCDEF" > strings/0x409/serialnumber
      echo "Radxa" > strings/0x409/manufacturer
      echo "Rock 5B Gadget" > strings/0x409/product

      mkdir -p configs/c.1/strings/0x409
      echo "Config 1: ECM Network & Serial" > configs/c.1/strings/0x409/configuration
      echo 250 > configs/c.1/MaxPower

      # Feature 1: USB Serial (ACM)
      mkdir -p functions/acm.usb0
      ln -s functions/acm.usb0 configs/c.1/

      # Feature 2: USB Network (ECM)
      mkdir -p functions/ecm.usb0
      ln -s functions/ecm.usb0 configs/c.1/

      # Bind to UDC
      UDC_NAME=$(ls /sys/class/udc | head -n 1)
      if [ -n "$UDC_NAME" ]; then
        echo "$UDC_NAME" > UDC
      else
        echo "Error: No USB Device Controller found."
        exit 1
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
