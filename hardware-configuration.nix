{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Módulos necesarios para NVMe y USB
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # ============================================================
  # SISTEMAS DE ARCHIVOS — nvme1n1 (disco 1.8TB donde va NixOS)
  # ============================================================

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d11b5c46-88c5-4b60-bcfd-c628eb72c9d8";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d11b5c46-88c5-4b60-bcfd-c628eb72c9d8";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/d11b5c46-88c5-4b60-bcfd-c628eb72c9d8";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noatime"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/d11b5c46-88c5-4b60-bcfd-c628eb72c9d8";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noatime"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/d11b5c46-88c5-4b60-bcfd-c628eb72c9d8";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noatime"
    ];
  };

  # Partición EFI / boot (nvme1n1p1)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9B54-540D";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
      "utf8"
    ];
  };

  # ============================================================
  # SWAP — ZRAM (igual que tenías en Arch, mejor que swap en SSD)
  # ============================================================
  zramSwap = {
    enable = true;
    memoryPercent = 25; # 25% de 24GB RAM = ~6GB de swap comprimido
  };

  # ============================================================
  # CPU AMD Ryzen 7 7435HS
  # ============================================================
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
