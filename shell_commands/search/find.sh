printf "Exiting, execution...\n"
exit 0;
# Parts of the 'Find' Command
# find location comparison-criteria search-term

# List all files in current and sub directories
find
find .
find . -print

# Search specific directory or path
find ./DIRNAME
find ./DIRNAME -name "FILENAME"

## Using wildcards
find ./DIRNAME -name "*.FILEEXT"

## Using wildcards and ignorecase
find ./DIRNAME -iname "*.Fileext"

# Limit depth of directory traversal
find ./DIRNAME -maxdepth 2 -name "*.FILEEXT"
find ./DIRNAME -maxdepth 1 -name "*.FILEEXT"

# Invert match
find ./DIRNAME -not -name "*.FILEEXT"
find ./DIRNAME ! -name "*.FILEEXT"

# Combine multiple search criterias
## Find with patter and not specific file extension.
find ./test -name 'PATTERN*' ! -name '*.FILEEXT'
## Find with patter or specific file extension.
find  -name 'PATTERN*' -o -name '*.FILEEXT'

# Search only files or only directories
find ./DIRNAME -name PATTERN*

## File search only
find ./DIRNAME -type f -name "PATTERN*"

## Directory search only
find ./DIRNAME -type d -name "PATTERN*"

# Search multiple directories together
find ./DIRNAME1 ./DIRNAME2 -type f -name "PATTERN*"

# Find hidden files
find ~ -type f -name ".*"

# Find files with certain permissions
find . -type f -perm 0664

## Inversion can also be applied to permission checking
find . -type f ! -perm 0777

# Find files with sgid/suid bits set
## The following command finds all files with permission 644 and sgid bit set
find / -perm 2644

### Similarly use 1664 for sticky bit. The perm option also supports using an alternative syntax instead of octal numbers.
find / -maxdepth 2 -perm /u=s 2>/dev/null

# Find Readonly files
## Find all Read Only files.
find /etc -maxdepth 1 -perm /u=r

# Find executable files
find /bin -maxdepth 2 -perm /a=x

# Find files owned to particular user
find . -user USERNAME
## Find files owned to particular user with criteria
find . -user USERNAME -name '*.FILEEXT'

# Search files belonging to group
find /DIR/SUBDIR -group GROUPNAME
## Searching in home directory for pattern
find ~ -name "FILENAME"

# Find files modified N days back
## Modified files 30 days back
find / -mtime 30

# Find files accessed in last N days
## Accessed files 30 days back
find / -atime 30

# Find files modified in a range of days
## Find all files that were modified between 30 to 60 days ago (i.e. includes 31-59)
find / -mtime +30 –mtime -60

# Find files changed in last N minutes (i.e. includes 0-59 seconds)
find /DIR/SUBDIR -cmin -60

# Files modified in last hour
find / -mmin -60

# Find Accessed Files in Last 1 Hour
find / -amin -60

# Find files of given size
find / -size 50M

# Find files in a size range
find / -size +50M -size -100M

# Find largest and smallest files
## The following command will display the 5 largest file
## in the current directory and its subdirectory
find . -type f -exec ls -s {} \; | sort -n -r | head -5

## Sorted in ascending order, it would show the smallest files first
find . -type f -exec ls -s {} \; | sort -n | head -5

# Find empty files and directories
find /tmp -type f -empty
find ~/ -type d -empty

# List out the found files
find . -exec ls -ld {} \;

# Delete all matching files or directories
## Remove all text files in the DIRNAME directory
find /DIRNAME -type f -name "*.FILEEXT" -exec rm -f {} \;

## Delete files larger than 100MB
find /DIR/SUBDIR -type f -name *.log -size +100M -exec rm -f {} \;

# Example Script: Find all directories in root and list their sizes
# Define an array to store directories instead of parsing output
REGEXP="media|mnt|tmp|srv|sys|var|proc|run|dev|lost+found"
declare -a dirs=( $(sudo find /* -maxdepth 0 -type d | grep -vE "${REGEXP}") )

# Process each directory in the array
for dir in "${dirs[@]}"; do
    # Print colored text for directory header
    printf "\033[36m%s\033[34m\n\t" "$dir"
    
    # Suppress du error messages and only show file sizes in a column
    sudo du -sh "$dir" 2>/dev/null | while IFS= read -r -r size; do
        echo " $size "
    done
done

##### END OF SCRIPT #####