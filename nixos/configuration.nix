# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  python-with-my-packages = pkgs.callPackage ./etc/python.nix {};
in  
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./etc/zsh.nix
    ];

  #Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
 # networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  
  # Configure network proxy if necessary
   networking.proxy.default = "http://127.0.0.1:7890";
   networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
   
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
    inputMethod.enabled = "ibus";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [ /* any engine you want, for example */ libpinyin ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.dpi = 200;
  
  # Enable the Plasma 5 Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  #GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.anap = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker"  ]; # Enable ‘sudo’ for the user.
   };

  # List packages installed in system profile. To search, run:
  nixpkgs.config.allowUnfree = true;
 

  # $ nix search wget
   environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     firefox
     nano
     clash
     pamixer # 音量控制
     brightnessctl # 屏幕亮度 
     neofetch onefetch 
     htop  
     ranger
     vlc # obs-studio 
     simplescreenrecorder
     # AppImage  
     appimage-run
     vscode
     jdk17
     efibootmgr
     github-desktop
     nodejs
     netease-cloud-music-gtk
     tdesktop 
     python-with-my-packages
     google-chrome
     jetbrains.idea-ultimate
     jetbrains.pycharm-professional
   ];


   
  #programs.tmux.keyMode = emacs;

   virtualisation.virtualbox.host.enable = true;
   users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

   virtualisation.docker.enable = true;



   
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
fonts = {
        enableDefaultFonts = true;
        fontconfig = {
          enable = true;
          hinting = {
            enable = true;
            autohint = false;
            # hintstyle = "hintslight(10px,12px)";
          };
	  defaultFonts.emoji = [ "Noto Color Emoji" ];
          defaultFonts.monospace = [ "Hack" "Sarasa Mono SC" ];
          defaultFonts.serif = [ "Source Han Serif SC" ];                
	};
        
        fontDir.enable = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
          sarasa-gothic
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          wqy_microhei
          wqy_zenhei
          jetbrains-mono
        ];
  };  
  #SSD Fstrim
  services.fstrim = {
  enable = true;
  interval = "tuesday";  
  };
  # List services that you want to enable:
  #GPU
  services.xserver.videoDrivers = [ "nvidia" "vesa" "modesetting" ]; #"nvidia"
  services.xserver.useGlamor = true;
  # hardware.bumblebee.enable = true;
  hardware = {
    nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Enable OpenCL support for Intel Gen8 and later GPUs
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;  
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firef>
      vaapiVdpau    
      libvdpau-va-gl
    ];
  };  
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

