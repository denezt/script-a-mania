#!/bin/bash

version='v0.0.1'

error(){
	printf "\033[35mError:\t\033[31m${1}\033[0m\n"
	return 1;
}

echo "Welcome to the Bash REPL!"
echo "Type 'exit' to quit."

while true;
do
	# Prompt for user input
	read -p ">> " input
	# Exit condition
	case "${input}" in
	exit|quit)
 		echo "Goodbye!"
		break
		;;
	version) echo "${version}";;
	esac
	# Evaluate the input as a Bash command
	eval "$input" 2> /dev/null || error "Problem occurred unable to perform ${input}!"
done
