#!/bin/bash

error(){
	printf "\033[35mError:\t\033[31m${1}\033[0m\n"
	exit 1
}

while getopts n:c: option
do
	case "${option}" in
        n) nation=${OPTARG};;
        c) code=${OPTARG};;
	*) error "Bad or invalid parameter was given";;
	esac
done

echo "Nation : $nation"
echo "code   : $code"
