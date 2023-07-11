# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user="craig";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-d64fa5d6-bcbc-4582-97f4-2362aabb7a72".device = "/dev/disk/by-uuid/d64fa5d6-bcbc-4582-97f4-2362aabb7a72";
  boot.initrd.luks.devices."luks-d64fa5d6-bcbc-4582-97f4-2362aabb7a72".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hosts = {
  "172.17.2.25" = [ "qnap" ];
  };
  
  fileSystems."/home/craig/nfs" = {
    device = "qnap:/craig";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
    
  
  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.windowManager.qtile.enable = true;
  
  # MISC Services to enable
  services.pcscd.enable = true;
  
  #Polkit and Agent
  security.polkit.enable = true;
  systemd = {
  user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
                    };
                };
    };

  programs.dconf.enable = true;
  services.flatpak.enable = true;
  xdg.portal = {
     enable = true;
     extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  #Virtualization Config
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "lpd" "libvirtd" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

 
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  environment.systemPackages = with pkgs; [
    vim
    wget
    neofetch
    neovim
    exa
    vimPlugins.dracula-vim
    vimPlugins.dracula-nvim
    vimPlugins.catppuccin-vim
    vimPlugins.catppuccin-nvim
## Virtual Support Packages ##
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
##-------------------------##

#Ledger Live
 (writeShellScriptBin "ledger.sh" ''
   appimage-run "/home/${user}/Applications/Ledger.AppImage";
'')
#Trezor Suite
 (writeShellScriptBin "trezor.sh" ''
   appimage-run "/home/${user}/Applications/Trezor.AppImage";
'')

  ];
  
  
  
  # Fonts
  fonts.fonts = with pkgs; [    
    font-awesome
    font-awesome_5
    font-awesome_4
    jetbrains-mono
    nerdfonts
    meslo-lgs-nf
    ubuntu_font_family
    google-fonts
  ];   
  
  programs.zsh.enable = true;
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
  system.stateVersion = "23.05"; # Did you read the comment?

### HOME MANAGER MODULE ###
  
  home-manager.users.${user} = { pkgs, ... }: {
  home.stateVersion = "23.05";
  home.packages = with pkgs; [
     arandr
     galculator
     yubikey-manager
     yubikey-agent
     hplipWithPlugin
     htop
     btop
     flameshot
     polybar
     picom
     #picom-jonaburg
     rofi
     geany
     pcmanfm
     nitrogen
     feh
     lxappearance
     networkmanagerapplet
     udiskie
     udisks
     meld
     polkit_gnome
     timeshift
     viewnior
     bitwarden
     google-authenticator
     google-chrome
     tor
     tor-browser-bundle-bin
     torsocks
     vlc
     veracrypt
     font-manager 
     volumeicon
     keepassxc
     betterlockscreen
     oh-my-zsh
     appimage-run
     yubioath-flutter
     yubikey-manager
     yubikey-agent
     guake
     glances
     brave
     signal-desktop
     telegram-desktop
     gimp-with-plugins
     
 #Themes
     dracula-theme
     dracula-icon-theme
     catppuccin-gtk 
     catppuccin-kde
     catppuccin-cursors
     catppuccin-papirus-folders 

   ];
 
#Services 
  services.dunst.enable = true;
  nixpkgs.config.allowUnfree = true;
  

#Programs
  
  #SSH
  programs.ssh = {
   enable = true;
   forwardAgent = true;
   hashKnownHosts = true;
   };

  #ZSH
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "docker-compose" "docker" "ssh-agent" "git" ];
      theme = "michelebologna";
    };
    initExtra = ''
      bindkey '^f' autosuggest-accept
      neofetch
      alias vim="nvim"
      alias ls="exa -la --group-directories-first"
    '';
  };

  #KITTY
  programs.kitty = {
  enable = true;
  font.name = "meslo-lgs-nf";
  font.size = 12;
  settings.scrollback_lines = "10000";
  };
	programs.kitty = {
	extraConfig = ''
	include /home/craig/github/mainsys/.config/kitty/kitty-themes/themes/Dracula.conf
	confirm_os_window_close 0
        background_opacity 0.8
        dynamic_background_opacity yes
    '';
  };

  #GITHUB
  programs.git = {
    enable = true;
    userEmail = "craigdolson@gmail.com";
    userName = "Craig Olson";
    difftastic.enable = true;
    difftastic.background = "dark";
    difftastic.color = "always";
    difftastic.display = "inline";
	};

  #BSPWM
  xsession.windowManager.bspwm.enable = true;
  xsession.windowManager.bspwm.monitors	= {
  HDMI-1 = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      ];
	};

  xsession.windowManager.bspwm.settings = {
      border_width = 1;
      window_gap = 10;
      normal_border_color = "#44475a";
      active_border_color = "#6272a4";
      focused_border_color = "#8be9fd";
      presel_feedback_color = "#6272a4";
      pointer_follows_focus = false;
      focus_follows_pointer = true;
      split_ratio = 0.55;
      borderless_monocle = true;
      gapless_monocle = true;
	};

  xsession.windowManager.bspwm.rules = {
	"Nm-connection-editor" = {
      state = "floating";
    };
	"Galculator" = {
      state = "floating";
    };
	"firefox" = {
      desktop = "^2";
      follow = true;
      };
	};

  xsession.windowManager.bspwm.startupPrograms = [
    #/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    "~/github/nixos/work-pc/scripts/autostart.sh"
    "nitrogen --restore"
    "/home/craig/.config/polybar/launch.sh"
    "picom"
    "flameshot"
    "nm-applet"
    "udiskie -t"
    "volumeicon"
];

 #SXHKD
 services.sxhkd = {
    enable = true;

 keybindings = {
  # Custom
    "super + Return" = "kitty";
    "super + b" = "firefox";
    "super + @space" = "$HOME/.config/rofi/launchers/type-3/launcher.sh";
    "super + Escape" = "pkill -USR1 -x sxhkd";

  #BSPWM
  # quit/restart bspwm
    "super + alt + {q,r}" = "bspc {quit,wm -r}";
  # Logout/Lock/Poweroff
    "super + ctrl + q" = "$HOME/.config/rofi/powermenu/type-2/powermenu.sh";
  # close and kill
    "super + {_,shift + }q" = "bspc node -{c,k}";
  # alternate between the tiled and monocle layout
    "super + m" = "bspc desktop -l next";
  # send the newest marked node to the newest preselected node
    "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";
  # swap the current node and the biggest window
    "super + g" = "bspc node -s biggest.window";

#
# state/flags
#

  # set the window state
    "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
  # set the node flags
    "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

#
# focus/swap
#

  # focus the node in the given direction
    "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";
  # focus the node for the given path jump
  # super + {p,b,comma,period}
  # bspc node -f @{parent,brother,first,second}
  # focus the next/previous window in the current desktop
    "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window";
  # focus the next/previous desktop in the current monitor
    "super + {Left,Right}" = "bspc desktop -f {prev,next}.local";
  # focus the last node/desktop
    "super + {grave,Tab}" = "bspc {node,desktop} -f last";
  # default config - replaced by "# KeyChord Focus / Send to desktiop on given monitor -- reddit post - IT WORKS"
  # focus or send to the given desktop
    "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}' --follow";
  # Change focused monitor
    "super + alt + {Left,Right}" = "bspc monitor -f {west,east}";
  # move and switch windows between monitors
    "super + {_,shift +} {comma, period}" = "bspc {monitor --focus,node --to-monitor} {prev,next} --follow";

    };
  };

 #VSCODE
     programs.vscode.enable = true;
     programs.vscode.enableExtensionUpdateCheck = true;
     programs.vscode.enableUpdateCheck = true;
     programs.vscode.package = pkgs.vscodium;
     programs.vscode.extensions = [
	pkgs.vscode-extensions.ms-python.python
        pkgs.vscode-extensions.dracula-theme.theme-dracula
         ];
     programs.vscode.userSettings = {
        "editor.fontFamily" = "'Droid Sans Mono', 'monospace', monospace, 'FontAwesome'";
        "workbench.colorTheme" = "Dracula";
        "security.workspace.trust.untrustedFiles" = "open";          
          };

#DOTFILE IMPORTS
  #qtile
     home.file.".config/qtile" = {
     source = /home/craig/github/nixos/work-pc/qtile;
     recursive = true;
     };
  #polybar
     home.file.".config/polybar" = {
     source = /home/craig/github/nixos/work-pc/polybar;
     recursive = true;
     executable = true;
     };
   #picom
     home.file.".config/picom" = {
     source = /home/craig/github/nixos/work-pc/picom;
     };
  #rofi
     home.file.".config/rofi" = {
     source = /home/craig/github/nixos/work-pc/rofi;
     recursive = true;
     executable = true;
     };


};
 
}
