{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [
    "nvme"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
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
      # The base ConfigFS path
      CONFIGFS="/sys/kernel/config/usb_gadget/rock5b"
      
      # Clean up any existing configurations (cynical reset)
      if [ -d "$CONFIGFS" ]; then
        rm -f $CONFIGFS/os_desc/b.1
        rm -f $CONFIGFS/configs/c.1/*
        rm -f $CONFIGFS/configs/c.1/strings/0x409/*
        rmdir $CONFIGFS/configs/c.1 || true
        rmdir $CONFIGFS/functions/* || true
        rmdir $CONFIGFS/strings/0x409 || true
        rmdir $CONFIGFS || true
      fi

      # Create the new gadget
      mkdir -p $CONFIGFS
      cd $CONFIGFS
      
      # Define standard USB Identifiers (Vendor/Product IDs)
      echo 0x1d6b > idVendor  # Linux Foundation
      echo 0x0104 > idProduct # Multifunction Composite Gadget
      echo 0x0100 > bcdDevice # v1.0.0
      echo 0x0200 > bcdUSB    # USB 2.0
      echo 0xEF > bDeviceClass
      echo 0x02 > bDeviceSubClass
      echo 0x01 > bDeviceProtocol
      
      # Set English strings
      mkdir -p strings/0x409
      echo "0123456789ABCDEF" > strings/0x409/serialnumber
      echo "Radxa" > strings/0x409/manufacturer
      echo "Rock 5B Gadget" > strings/0x409/product

      # Create a configuration profile
      mkdir -p configs/c.1/strings/0x409
      echo "Config 1: ECM Network & Serial" > configs/c.1/strings/0x409/configuration
      echo 250 > configs/c.1/MaxPower

      # Feature 1: USB Serial (ACM)
      mkdir -p functions/acm.usb0
      ln -s functions/acm.usb0 configs/c.1/

      # Feature 2: USB Network (ECM)
      mkdir -p functions/ecm.usb0
      # Optional: set fixed MAC addresses so they don't randomize on every boot
      # echo "42:63:65:12:34:56" > functions/ecm.usb0/host_addr
      # echo "42:63:65:65:43:21" > functions/ecm.usb0/dev_addr
      ln -s functions/ecm.usb0 configs/c.1/

      # Bind the gadget to the UDC (USB Device Controller)
      # WARNING: 'fc000000.usb' is the typical address for RK3588 Type-C.
      # Run `ls /sys/class/udc` on your live system to verify your exact UDC name if it fails.
      UDC_NAME=$(ls /sys/class/udc | head -n 1)
      if [ -n "$UDC_NAME" ]; then
        echo "$UDC_NAME" > UDC
      else
        echo "Error: No USB Device Controller found. Check your device tree overlay."
        exit 1
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
