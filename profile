# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
if [ -n "$DISPLAY" ]; then
	echo "DISPLAY $DISPLAY :Not 1st login"
else 
	echo "NO DISPLAY 1st login - cd to start"
	cd ~/start
	ls
fi

#setup DISPLAY at first login
export DISPLAY=127.0.0.1:0.0
set -o vi

if [ -e $HOME/dotfiles/alias ]; then
    source $HOME/dotfiles/alias
fi
alias a='$HOME/dotfiles/alias'

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "/mnt/d/c" ] ; then
	cd /mnt/d/c
else 
	sudo mount -t drvfs d: /mnt/d
	cd /mnt/d/c
fi

PATH=./:$PATH
