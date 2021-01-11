#!/bin/bash

_rcfile=".bashrc"
_gf="global_funcs.sh"

add_script(){
	if [ ! -e "${HOME}/${_gf}" ];
	then
		cp -a -v "${_gf}" ${HOME}/
	else
		printf "Found script -> ${HOME}/${_gf}\n"
	fi
}

add_to_bashrc(){
	echo "Add To BASHRC"
	message='Loading, Global Functions...'
	printf "\nif [ -e \'${HOME}/${_gf}\' ];\nthen\n\techo \'${message}\'\n\t. ${HOME}/${_gf}\nfi\n" >> ${HOME}/${_rcfile}
	printf "\033[35mReload \033[34m\'${_rcfile}\' \033[35mfile.\033[0m? [ \033[32m(y)es\033[0m, \033\31m(n)o\033[0m ] "
	read _confirm
	case $_confirm in
		y|yes) exec bash;;
		n|no) printf "\033[34mExiting, nothing was executed.\033[0m\n";;
	esac
}

_found=($(egrep -o "${_gf}" ${HOME}/${_rcfile}))
case ${#_found} in
	0) add_script && add_to_bashrc;;
	*) printf "\033[32mGlobal Functions scripts \033[33m\'${_gf}\'\033[0m \033[32mis already in ${HOME}/${_rcfile}.\033[0m\n";;
esac

