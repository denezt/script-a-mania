#!/bin/bash

for f in `sudo printf "$(ls /)"`;
do
	printf "${f}\n";
	sudo du -sh "/${f}";
done

