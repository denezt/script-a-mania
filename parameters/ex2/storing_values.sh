#!/bin/bash

error(){
	printf "\033[35mError:\t\033[31m${1}\033[0m\n"
	exit 1
}

while getopts n:o:p: option
do
	case "${option}" in
        n) n=${OPTARG};;
        o) o=${OPTARG};;
        p) p=${OPTARG};;
	*) error "Bad or invalid parameter was given";;
	esac
done

echo "scale=8;s($n) * ${p} / c($RANDOM)" | bc -l
