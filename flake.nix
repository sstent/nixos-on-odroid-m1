{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  };

  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    lib = nixpkgs.lib;

  

  in rec {
    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        rsync
        zstd
      ];
    };

    nixosConfigurations.m1 = lib.nixosSystem {
      system = "aarch64-linux";

      modules = [
      ({ pkgs, config, ... }: {

          imports = [
            ./kboot-conf
            # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

          ];

          sdImage = {
            #compressImage = false;
            populateFirmwareCommands = let
              configTxt = pkgs.writeText "README" ''
              Nothing to see here. This empty partition is here because I don't know how to turn its creation off.
              '';
            in ''
              cp ${configTxt} firmware/README
            '';
            populateRootCommands = ''
              ${config.boot.loader.kboot-conf.populateCmd} -c ${config.system.build.toplevel} -d ./files/kboot.conf
            '';
            };

          #boot.loader.grub.enable = false;
          boot.loader.kboot-conf.enable = true;
          # Use kernel >6.6 
          boot.kernelPackages = pkgs.linuxPackages_latest;
          # Stop ZFS breasking the build
          boot.supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];

          # I'm not completely sure if some of these could be omitted,
          # but want to make sure disk access works
          boot.initrd.availableKernelModules = [
            "nvme"
            "nvme-core"
            "phy-rockchip-naneng-combphy"
            "phy-rockchip-snps-pcie3"
          ];
          # Petitboot uses this port and baud rate on the boards serial port,
          # it's probably good to keep the options same for the running
          # kernel for serial console access to work well
          boot.kernelParams = [ "console=ttyS2,1500000" ];       
          hardware.deviceTree.name = "rockchip/rk3568-odroid-m1.dtb";

cloneConfig = true;          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };
          users.extraUsers.root.initialPassword = lib.mkForce "test123";
        })
      ];
    };

    images = {
      m1 = nixosConfigurations.m1.config.system.build.sdImage;
    };
  };
}
