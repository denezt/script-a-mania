#!/bin/bash

_timestamp=$(date '+%s')
reqs_file="requirements.txt"

# Install the pip requirements
pip3 install pipreqs
# Archive older Requirement if exists
[ -f "$reqs_file" ] && mv -v "${reqs_file}" "$(basename -s .txt ${reqs_file})-${_timestamp}.txt"
# Run in current directory
printf "\033[35mRunning, PIP requirements in current directory...\033[0m\n"
# Search and output current requirements to 'requirements.txt'
python3 -m  pipreqs.pipreqs .
printf "\033[32mDone!\033[0m\n"
