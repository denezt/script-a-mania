#!/bin/bash

error(){
	printf "\033[35mError:\t\033[31m${1}\033[0m\n"
	exit 1
}

while getopts a:b: option
do
	case "${option}" in
        a) p1=${OPTARG};;
        b) p2=${OPTARG};;
	*) error "Bad or invalid parameter was given";;
	esac
done

printf "Parameter [1]: p1=${p1}\n"
printf "Parameter [2]: p2=${p2}\n"
