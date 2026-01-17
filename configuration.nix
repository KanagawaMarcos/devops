
# ============================================================
# NixOS main system configuration
# File: /etc/nixos/configuration.nix
#
# Este arquivo define TODO o estado do sistema operacional:
# boot, drivers, desktop, usuários, pacotes, serviços, etc.
#
# Qualquer mudança aqui só tem efeito após:
#   sudo nixos-rebuild switch
# ============================================================

{ config, pkgs, ... }:

{
  # ==========================================================
  # IMPORTS
  # ==========================================================
  # Importa a configuração gerada automaticamente com base
  # no hardware detectado (discos, GPU, CPU, etc.)
  imports = [
    ./hardware-configuration.nix
  ];

  # ==========================================================
  # BOOTLOADER (UEFI + systemd-boot + GRUB compat)
  # ==========================================================
  boot.loader = {
    systemd-boot.enable = true;           # Bootloader padrão do NixOS
    efi.canTouchEfiVariables = true;       # Permite gravar variáveis EFI

    grub = {
      devices = [ "nodev" ];              # Necessário para UEFI puro
      efiSupport = true;                  # Suporte a EFI
      useOSProber = true;                 # Detecta outros SOs
      theme = "light";                    # Tema visual do GRUB
    };
  };

  # ==========================================================
  # NETWORKING
  # ==========================================================
  networking = {
    hostName = "nixos";                   # Hostname da máquina

    # Gerenciador de rede (Wi-Fi, Ethernet, VPNs, etc.)
    networkmanager.enable = true;

    # Exemplo de proxy (desativado)
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # ==========================================================
  # TIMEZONE & LOCALE
  # ==========================================================
  time.timeZone = "America/Fortaleza";

  # Locale padrão do sistema
  i18n.defaultLocale = "en_US.UTF-8";

  # Locale específico para formatos brasileiros
  i18n.extraLocaleSettings = {
    LC_ADDRESS       = "pt_BR.UTF-8";
    LC_IDENTIFICATION= "pt_BR.UTF-8";
    LC_MEASUREMENT   = "pt_BR.UTF-8";
    LC_MONETARY      = "pt_BR.UTF-8";
    LC_NAME          = "pt_BR.UTF-8";
    LC_NUMERIC       = "pt_BR.UTF-8";
    LC_PAPER         = "pt_BR.UTF-8";
    LC_TELEPHONE     = "pt_BR.UTF-8";
    LC_TIME          = "pt_BR.UTF-8";
  };

  # ==========================================================
  # DISPLAY SERVER & DESKTOP
  # ==========================================================
  services.xserver = {
    enable = true;                        # Ativa X11 (necessário mesmo com Wayland)

    # Layout de teclado no X11
    xkb = {
      layout = "br";
      variant = "";
    };

    # Driver de vídeo
    videoDrivers = [ "nvidia" ];
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Display Manager (login gráfico)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;                # Sessão Wayland ativa
  };

  # Teclado do console (TTY)
  console.keyMap = "br-abnt2";

  # ==========================================================
  # NVIDIA GPU
  # ==========================================================
  hardware.nvidia = {
    open = false;                          # Driver open kernel module
    modesetting.enable = false;            # Necessário para Wayland
    nvidiaSettings = true;                # Painel nvidia-settings
    powerManagement.enable = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ==========================================================
  # AUDIO (PipeWire)
  # ==========================================================
  services.pulseaudio.enable = false;     # Desativa PulseAudio antigo
  security.rtkit.enable = true;           # Prioridade realtime para áudio

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;                 # Descomentar se usar JACK
  };

  # ==========================================================
  # POWER MANAGEMENT & LID BEHAVIOR
  # ==========================================================
  services.power-profiles-daemon.enable = false;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";                 # Não suspende ao fechar tampa
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # ==========================================================
  # PRINTING, SCANNING & NETWORK DISCOVERY
  # ==========================================================
  services.printing = {
    enable = true;                        # CUPS
    drivers = [ ];
  };

  services.avahi = {
    enable = true;                        # mDNS / zeroconf
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.sane = {
    enable = true;                        # Scanner
    extraBackends = [ pkgs.sane-airscan ];
  };

  # ==========================================================
  # NIX & COMPATIBILITY
  # ==========================================================
  programs.nix-ld.enable = true;          # Executar binários não-Nix

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;      # Permite software proprietário

  # ==========================================================
  # USER ACCOUNT
  # ==========================================================
  users.users.kanagawamarcos = {
    isNormalUser = true;
    description = "Marcos Kanagawa";

    extraGroups = [
      "networkmanager"                   # Controle de rede
      "wheel"                            # sudo
      "uucp" "dialout"                   # Serial / Arduino
    ];

    packages = with pkgs; [
      # === System / Dev ===
      git git-lfs wget openssl zlib libgcc
      docker nodejs python3
      dotnetCorePackages.sdk_9_0-bin
      rustc rustup
      emacs vim vscode jetbrains.rider
      claude-code chromium
      pciutils
      mesa-demos

      # === Android / Embedded ===
      android-studio android-studio-tools
      arduino-ide

      # === Design / CAD / Maker ===
      inkscape-with-extensions
      freecad kicad easyeda2kicad
      blender krita gimp-with-plugins
      orca-slicer
      scribus code-cursor
      mkcert pnpm vlc
      ffmpeg-full
      #davinci-resolve-studio

      # === Media ===
      obs-studio audacity lmms
      kdePackages.kdenlive

      # === Communication ===
      thunderbird discord telegram-desktop signal-desktop
      localsend

      # === Gaming ===
      mangohud protonup-ng lutris heroic bottles godot

      # === Utilities ===
      xclip mission-center
      transmission_4
      bruno
      libreoffice
      scribus

      # === KDE ===
      kdePackages.kate
      kdePackages.isoimagewriter

      # === Epson ===
      epson_201207w
      epson-escpr
      epson-escpr2

      # === Boot / Theme ===
      sleek-grub-theme
    ];
  };

  # ==========================================================
  # GAMING SYSTEM
  # ==========================================================
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # ==========================================================
  # BROWSERS
  # ==========================================================
  programs.firefox.enable = true;

  # ==========================================================
  # ENVIRONMENT VARIABLES
  # ==========================================================
  environment.variables = {
    GTK_ENABLE_PRIMARY_PASTE = "false";   # Tentativa de desativar middle-click paste
  };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";

    #desativado para KDENLIVE funcionar #NIXOS_OZONE_WL = "1";                 # Melhor suporte Wayland
    #desativado para kdenlive funcioncar #KWIN_DRM_USE_EGL_STREAMS = "0";       # Corrige NVIDIA + Wayland
  };


  # ==========================================================
  # SYSTEM VERSION (NUNCA ALTERAR LEVEMENTE)
  # ==========================================================
  system.stateVersion = "25.11";
}


