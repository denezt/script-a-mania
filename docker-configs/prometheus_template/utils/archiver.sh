#!/bin/bash

set -euo pipefail

# Check if the source directory is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

source_dir="$1"

# Create archives directory if it doesn't exist
mkdir -p archives

# Get current timestamp for filename
timestamp=$(date '+%s')

# Create target archive filename
target_file="archives/${source_dir}_${timestamp}.7z"

# Run 7zip with specified parameters
7z a -t7z -mx=9 -mfb=273 -ms -md=31 -myx=9 -mtm=- -mmt -mmtf -md=1536m -mmf=bt3 -mmc=10000 -mpb=0 -mlc=0 "$target_file" "$source_dir"

# Check if archiving was successful
if [ $? -eq 0 ]; then
    echo "Successfully archived $source_dir to $target_file"
else
    echo "Failed to archive $source_dir"
    exit 1
fi
