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

  networking.hostName = "tipi";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];

  # Needed to preserve current working directory when opening new tabs.
  environment.interactiveShellInit = ". ${pkgs.gnome3.vte}/etc/profile.d/vte.sh";

  programs.bash.enableCompletion = true;

  nix.useChroot = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    # https://github.com/NixOS/nixpkgs/commit/b741df943fbe7dbbf8d2f295f9aaa0ce3991a5d2
    system-config-printer = callPackage ./packages/system-config-printer/default.nix {};
  };

  # https://github.com/NixOS/nixpkgs/issues/15005
  # https://github.com/NixOS/nixpkgs/issues/16609
  #virtualisation.virtualbox.host.enable = true;

  # List services that you want to enable:

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql94;
  services.postgresql.authentication = "local all all ident";

  services.redis.enable = true;
  services.locate.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # https://bugzilla.redhat.com/show_bug.cgi?id=1327495
  #services.fprintd.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.layout = "us";
  #services.xserver.xkbOptions = "eurosign:e";
  #services.xserver.xkbVariant = "altgr-intl";

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.xserver.displayManager.gdm.autoLogin.enable = true;
  services.xserver.displayManager.gdm.autoLogin.user = "martijn";

  services.xserver.synaptics.enable = true;
  services.xserver.synaptics.accelFactor = "0.02";

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

  # Todo: This will change after NixOS 16.03.
  # https://github.com/NixOS/nixpkgs/pull/14012
  services.xserver.startGnuPGAgent = true;
  services.xserver.startSSHAgent = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.martijn = {
    description = "Martijn Vermaat";
    hashedPassword = "$6$LuPQ7sp08p5o$0KLSCqX5WM1J/kSyAztLi2/s.pH9RHS63bt9qDUhbM2/S9b6IGVUtaInlbpULaeYozTk2apYYjkmBMxfzAbjN/";
    uid = 1000;
    isNormalUser = true;
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "vboxuser" ];
    home = "/home/martijn";
  };

  users.mutableUsers = false;

  # Links this file from /run/current-system/configuration.nix which can be
  # useful for debugging.
  system.copySystemConfiguration = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
