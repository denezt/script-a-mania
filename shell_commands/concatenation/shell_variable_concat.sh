#!/bin/bash

# Initialize an empty variable
global_var=""
# Concatenate items into a single variable separated by ';'
for a in $(for i in {1..50}; do echo "$(uuidgen | tr -d '-')"; done);
do
    # Append with ';' separator
	global_var="${global_var};${a}";
done;

# Remove leading and trailing '|'
printf "${global_var}\n" | sed 's/^;//g' | sed 's/;$//g';