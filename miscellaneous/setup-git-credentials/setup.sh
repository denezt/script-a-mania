#!/bin/bash

gitcreds="$HOME/.git-credentials"
if [ ! -f "${gitcreds}" ];
then
	printf "# https://USERNAME:GIT_TOKEN@git.domain.com" > ${gitcreds}
else
	printf "Found Git Credentials: ${gitcreds}\n"
fi

# Store
git config --global credential.helper store

config="$HOME/.gitconfig"
if [ -f "${config}"  ];
then
	printf "\033[35mFound config \033[32m${config}\033[0m. \033[34mDo you want to view it?\033[0m\n"
	read -p "[yes|no] " _confirm
	case $_confirm in
		y|yes|Y|Yes) printf "\033[36m\n";cat ${config};printf "\033[0m\n";;
	esac
else
	printf "No `.gitconfig` does not exist.\n"
fi

if [ -f "${config}" ];
then
	for cfg in 'user.name' 'user.email';
	do
		if [ -z "$(git config --local ${cfg})" ];
		then
			printf "Missing ${cfg} parameter.\n"
			printf "Would you like to add this parameter?\n"
			read -p "[yes|no] " _confirm
			case $_confirm in
				y|yes|Y|Yes)
				printf "Enter value for ${cfg}:\n"
				read _value
				if [ -n "${_value}" ];
				then
					git config --local ${cfg} "${_value}"
				else
					printf "No valid ${cfg} value was given!\n"
				fi
				;;
			esac
		fi
	done
	printf "\033[33mView Global Settings:\033[0m\n"
	printf "\033[36m\n"
	for cfg in $(git config --local --list);
	do
		printf "${cfg}\n"
	done
	printf "\033[0m\n"
fi
