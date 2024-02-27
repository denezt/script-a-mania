#!/bin/bash

# Default configuration to disable external GPU
# as main display device
srcfile="etc/X11/xorg.conf"
# File destination for configuration
targetfile="/etc/X11/xorg.conf"

add_default_conf(){
	# Data from default configuration file
	printf "\033[35mLocal Source ${srcfile}:\n\033[33m$(cat ${srcfile})\033[0m\n"
	# Add the default display configuration to xorg configuration
	printf "\033[96mAdding Local Source entry into: \033[32m${targetfile}\033[0m\n"
	read -p "Are you sure? [y|n]: " _confirm
	case $_confirm in
		y|yes) cat ${srcfile} | sudo tee -a ${targetfile}
		[ -n "$(egrep --file=${srcfile} ${targetfile})" ] && printf "\033[32mSuccessfully, updated the XORG configuration!!\033[0m\n"
		;;
		*) printf "\033[36mExiting, no configuration update was executed.\033[0m\n";;
	esac
}

if [ -e "${targetfile}" ];
then
	# Compare default configuration file with target
	if [ -n "$(egrep --file=${srcfile} ${targetfile})" ];
	then
		printf "\033[32mFound entry in current XORG configuration file!\033[0m\n"
		printf "\033[35mCurrent Source file: ${targetfile}:\n\033[92m$(egrep --file=${srcfile} ${targetfile})\033[0m\n"
	else
		add_default_conf
	fi
else
	printf "\033[34mInfo: \033[36mMissing or unable to find local configuration \033[33m${targetfile}\033[0m\n"
	add_default_conf
fi
