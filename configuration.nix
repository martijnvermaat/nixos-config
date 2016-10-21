# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Oh yes living on the edge.
  boot.kernelPackages = pkgs.linuxPackages_4_8;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/06e7d974-9549-4be1-8ef2-f013efad727e";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  boot.cleanTmpDir = true;

  # Some configuration for those annoying Apple keyboards.
  boot.extraModprobeConfig = ''
    # Function/media keys:
    #   0: Function keys only.
    #   1: Media keys by default.
    #   2: Function keys by default.
    options hid_apple fnmode=2

    # Fix tilde/backtick key.
    options hid_apple iso_layout=0

    # Swap Alt key and Command key.
    options hid_apple swap_opt_cmd=1
  '';

  networking.hostName = "tipi";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  #time.timeZone = "US/Eastern";
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];

  # Needed to preserve current working directory when opening new tabs.
  environment.interactiveShellInit = ". ${pkgs.gnome3.vte}/etc/profile.d/vte.sh";

  programs.bash.enableCompletion = true;

  programs.ssh.startAgent = true;

  nix.useSandbox = true;

  nixpkgs.config.allowUnfree = true;

  # https://github.com/NixOS/nixpkgs/issues/15005
  # https://github.com/NixOS/nixpkgs/issues/16609
  #virtualisation.virtualbox.host.enable = true;

  virtualisation.docker.enable = true;

  # List services that you want to enable:

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql94;
  services.postgresql.authentication = "local all all ident";

  services.rabbitmq.enable = true;

  services.redis.enable = true;

  services.locate.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # https://bugzilla.redhat.com/show_bug.cgi?id=1327495
  #services.fprintd.enable = true;

  services.avahi.enable = true;
  services.avahi.hostName = "tipi";
  services.avahi.browseDomains = [ ];
  services.avahi.nssmdns = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.layout = "us";
  #services.xserver.xkbOptions = "eurosign:e";
  #services.xserver.xkbVariant = "altgr-intl";

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.xserver.displayManager.gdm.autoLogin.enable = true;
  services.xserver.displayManager.gdm.autoLogin.user = "martijn";

  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.2";
  services.xserver.libinput.tappingDragLock = false;

  #Option "Scale"   "1.5x1.5"
  #services.xserver.monitorSection = ''
  #  Option "Panning" "3840x2160"
  #'';

  # NOTE: Gnome only uses half of the screen with these settings.
  #services.xserver.displayManager.sessionCommands = ''
  #  xrandr --output eDP1 --scale 1.5x1.5
  #  xrandr --output eDP1 --panning 3840x2160
  #'';

  # Screen is 14" at 2560x1440 (16:9), so 31.00x17.43cm. Using
  # steps of 25% from the standard 96dpi, the closest we get is
  # 225% or 216dpi (30.1x16.9cm reported by xdpyinfo).
  # https://wiki.archlinux.org/index.php/Xorg#Setting_DPI_manually
  # TODO: In current NixOS master there is a services.xserver.dpi
  # option.
  # https://github.com/NixOS/nixpkgs/pull/14549
  # NOTE: Seems to be overwritten by Gnome.
  #services.xserver.displayManager.xserverArgs = [ "-dpi 216" ];

  services.gnome3.tracker.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.martijn = {
    description = "Martijn Vermaat";
    hashedPassword = "$6$LuPQ7sp08p5o$0KLSCqX5WM1J/kSyAztLi2/s.pH9RHS63bt9qDUhbM2/S9b6IGVUtaInlbpULaeYozTk2apYYjkmBMxfzAbjN/";
    uid = 1000;
    isNormalUser = true;
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "vboxuser" "docker" ];
    home = "/home/martijn";
  };

  users.mutableUsers = false;

  # Links this file from /run/current-system/configuration.nix which can be
  # useful for debugging.
  system.copySystemConfiguration = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
