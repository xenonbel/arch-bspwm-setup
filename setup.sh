#!/bin/bash

IsRoot() {
    if [[ $EUID -eq 0 ]]; then
        echo "This script should NOT be run as root!"
        exit 1
    fi
}

CheckCurlAndGit() {
    echo "Checking for required tools..."

    if ! command -v curl &> /dev/null; then
        echo "curl is not installed."
        read -p "Install curl? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -Sy --noconfirm curl
        else
            echo "curl is required. Exiting."
            exit 1
        fi
    else
        echo "curl found."
    fi

    if ! command -v git &> /dev/null; then
        echo "git is not installed."
        read -p "Install git? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -Sy --noconfirm git
        else
            echo "git is required. Exiting."
            exit 1
        fi
    else
        echo "git found."
    fi
}

HelloScreen() {
    echo '==========================================================='
    echo 'Arch Linux bspwm setup script'
    echo 'Modern minimalist configs + icons'
    echo '==========================================================='
}

UpdateRepositoriesDB() {
    sudo pacman -Sy --noconfirm
}

InstallXorg() {
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xsetroot xorg-xrandr
}

InstallMainPackages() {
    sudo pacman -S --noconfirm bspwm sxhkd rofi polybar alacritty feh gnu-free-fonts git
}

InstallPicom() {
    sudo pacman -S --noconfirm --needed base-devel git
    cd /tmp || exit
    git clone https://aur.archlinux.org/picom-ftlabs-git.git 
    cd picom-ftlabs-git || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf picom-ftlabs-git/
}

InstallParu() {
    cd /tmp || exit
    git clone https://aur.archlinux.org/paru.git 
    cd paru || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf paru/
}

InstallThemesAndIcons() {
    sudo pacman -S --noconfirm papirus-icon-theme lxappearance
    paru -S --noconfirm catppuccin-gtk-theme-mocha
}

InstallBetterlockscreen() {
    paru -S --noconfirm betterlockscreen
}

CreateModernConfigs() {
    mkdir -p ~/.config/{bspwm,sxhkd,polybar}
    curl -sLo ~/.config/bspwm/bspwmrc https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/bspwm/bspwmrc 
    chmod +x ~/.config/bspwm/bspwmrc
    curl -sLo ~/.config/sxhkd/sxhkdrc https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/sxhkd/sxhkdrc 
    echo "exec bspwm" > ~/.xinitrc
    mkdir -p ~/.config/polybar
    curl -sLo ~/.config/polybar/config https://raw.githubusercontent.com/adi1090x/polybar-themes/master/forest/config.ini 
    curl -sLo ~/.config/polybar/launch.sh https://raw.githubusercontent.com/adi1090x/polybar-themes/master/forest/launch.sh 
    chmod +x ~/.config/polybar/launch.sh
}

InstallLightDM() {
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
}

IsRoot
CheckCurlAndGit
HelloScreen
UpdateRepositoriesDB
InstallXorg
InstallMainPackages

read -p "Install paru AUR helper? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    InstallParu
fi

read -p "Install picom (compositor)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    InstallPicom
fi

read -p "Install themes and icons (Catppuccin, Papirus)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    InstallThemesAndIcons
fi

read -p "Install betterlockscreen (screen locker)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    InstallBetterlockscreen
fi

CreateModernConfigs
InstallLightDM

echo "Installation complete!"
echo "You can now run 'startx' to start the graphical environment"
echo "Or reboot and log in via LightDM: sudo reboot"
