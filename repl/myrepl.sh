#!/bin/bash

echo "Welcome to the Bash REPL!"
echo "Type 'exit' to quit."

while true; do
    # Prompt for user input
    read -p ">> " input

    # Exit condition
    if [ "$input" == "exit" ]; then
        echo "Goodbye!"
        break
    fi

    # Evaluate the input as a Bash command
    eval "$input"
done
