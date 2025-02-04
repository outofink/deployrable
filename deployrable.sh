#!/bin/bash

echo 'deployrable v0.1'
sleep 1
echo 'MIT License, Copyright (c) 2021 gsobell'
clear

TEMP=$(mktemp -d -t gsobell.XXXXXXXXXX)
cd $TEMP

echo 'Checking if git is installed'
if ! command -v git &> /dev/null; then
    sudo pacman -S git
fi

echo 'Cloning dotfile repo to local host'
git clone https://github.com/gsobell/dotfiles.git

# Initial dotfile deployment
mkdir -pv $HOME/.i3

mv -fv dotfiles/.Xresources	    $HOME/.Xresources
mv -fv dotfiles/.bashrc		    $HOME/.bashrc
mv -fv dotfiles/.bash_profile	$HOME/.bash_profile
mv -fv dotfiles/.vimrc		    $HOME/.vimrc
mv -fv dotfiles/.i3/config		$HOME/.i3/config

# Setting natural scrolling > Use xmodmap instead, look into libinput

if ! command -v paru &> /dev/null
then
    echo 'Refreshing databases'
    sudo pacman -Syy
    echo 'Installing Paru'
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd $TEMP
else
    echo 'Paru already installed, refreshing databases'
    sudo pacman -Syy
fi

echo "Install packages at this time? (Y/n)"
read yn
while true; do
    case $yn in
        [Yy]* ) ls dotfiles/packlist > packversion.txt
            select PACKLIST in $(cat packversion.txt) exit; do
                case $PACKLIST in
                    exit) echo "Exiting."
                        break ;;
                    *) echo "$PACKLIST"
                        echo Installing "$PACKLIST";
                        paru -S - < dotfiles/packlist/"$PACKLIST"
                        rm packversion.txt
                esac
            done; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no."; echo "Install packages now (Y/n)?"; read yn;;
    esac
done

if ! command -v nitrogen &> /dev/null
then
    echo 'Not setting wallaper'
else
    curl https://unsplash.com/photos/Dksk8szLRN0/ > $HOME/.default_wallpaper.png
    nitrogen $HOME/.default_wallpaper.png
    echo 'Wallpaper set.'
fi

echo 'Cleaning up.'
sleep 1
rm -fdr $TEMP
echo 'One moment please.'
sleep 1
echo "Setup complete, exiting deployrable."
sleep 1

rm -- "$0"
exit 0
