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
	echo "NO DISPLAY 1st login - cd to home"
	cd ~
fi

if [ ! -e /mnt/g/anaconda3/ ]
then sudo mount -t drvfs g: /mnt/g
fi

if [ ! -e /mnt/g/anaconda3/ ]
then echo no /mnt/g/anaconda3 found !
fi

#setup DISPLAY at first login
export DISPLAY=127.0.0.1:0.0
set -o vi

if [ -e $HOME/dotfile/alias ]
then source $HOME/dotfile/alias
fi
alias a='source $HOME/dotfile/alias'


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

PATH=./:$PATH
