# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

{
  # Imports
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
      #       (builtins.fetchTarball {
      #   url = "https://github.com/nix-community/lanzaboote/archive/master.tar.gz";
      # } + "/nix/module.nix")
    ];

  home-manager.backupFileExtension = "backup";

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    taskwarrior3
    git
    killall
    btop
    matugen
    neovim
    fzf
    direnv
    python311
    ffmpeg
    python314
    (wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) {})
    telegram-desktop
    kitty
    libreoffice-qt
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    obsidian
    obs-studio
    p7zip
    papers
    fastfetch
    jetbrains.idea-community
    quickshell
    gnome-shell-extensions
    grim
    playerctl
    satty
    yq-go
    xdg-desktop-portal-gtk
    eww
    swappy
    slurp
    mpvpaper
    gnome-tweaks
    pkgsCross.mingwW64.stdenv.cc
    wmctrl
    bottles
    qbittorrent
    power-profiles-daemon
    jdk8
    steam-run
    sbctl
    discord
  ];

  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # User accounts and security
  users.users.antonio = {
    isNormalUser = true;
    description = "antonio";
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" ];
    packages = with pkgs; [
      # thunderbird
    ];
    useDefaultShell = true;
    shell = pkgs.zsh;
  };

  users.defaultUserShell = pkgs.zsh;
  system.userActivationScripts.zshrc = "touch .zshrc";

  security.sudo.extraRules = [
    {
      users = [ "antonio" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  # Program configurations
  programs.zsh.enable = true;
  programs.adb.enable = true;
  programs.firefox.enable = true;

  programs.dconf = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  # Home manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.antonio = {
    imports = [ ./home.nix ];
  };

  # Desktop environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Hyprland
  programs.hyprland.enable = true;

  # XDG Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Teclado: español + ruso (cambia "us,ru" por "es,ru" o solo "es" si quieres)
  services.xserver.xkb = {
    layout = "es,ru";
    variant = "";
  };

  # Fonts
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf
  ];

  fonts.fontconfig = {
    enable = true;
    hinting.style = "slight";
    subpixel.rgba = "rgb";
  };

  # Flatpak
  services.flatpak.enable = true;

  # Networking
  networking.hostName = "nixlaptop";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # Zona horaria España
  time.timeZone = "Europe/Madrid";

  # Idioma del sistema (español)
  i18n.defaultLocale = "es_ES.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT    = "es_ES.UTF-8";
    LC_MONETARY       = "es_ES.UTF-8";
    LC_NAME           = "es_ES.UTF-8";
    LC_NUMERIC        = "es_ES.UTF-8";
    LC_PAPER          = "es_ES.UTF-8";
    LC_TELEPHONE      = "es_ES.UTF-8";
    LC_TIME           = "es_ES.UTF-8";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.blueman.enable = true;
  services.printing.enable = true;
  services.openssh.enable = false;
  services.power-profiles-daemon.enable = true;

  # Nix settings
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://cachyos.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachyos.cachix.org-1:7yuMBJFhFSxb1CkLHJAVhyFzFyRLsYELCDOtDkSO/I="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  # Boot / Plymouth
  boot = {
    plymouth = {
      enable = true;
      theme = "simple";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-simple";
          version = "1.0";
          src = /etc/nixos/config/programs/plymouth/simple;
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/simple
            cp -r * $out/share/plymouth/themes/simple/
            substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
              --replace "@out@" "$out"
          '';
        })
      ];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      # NO amd_pstate porque no tienes APU integrada activa
    ];
  };

  # Bootloader con Secure Boot via lanzaboote
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;

  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/etc/secureboot";
  # };

  # Kernel CachyOS (necesita el canal cachyos añadido)
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # Optimizaciones de red
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc"          = "fq";
    "net.core.wmem_max"               = 1073741824;
    "net.core.rmem_max"               = 1073741824;
    "net.ipv4.tcp_rmem"               = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem"               = "4096 87380 1073741824";
  };

  # CPU AMD — sin governor performance forzado para ahorrar batería en portátil
  # Puedes cambiar a "performance" si lo prefieres
  powerManagement.cpuFreqGovernor = "schedutil";

  # GPU — solo NVIDIA RTX 4060 Mobile (sin PRIME, sin AMD integrada)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Necesario para Steam
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;        # Recomendado en portátiles NVIDIA
    powerManagement.finegrained = false;  # Experimental, dejarlo en false
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Sin sección prime: tienes una sola GPU dedicada
  };

  system.stateVersion = "25.11";
}
