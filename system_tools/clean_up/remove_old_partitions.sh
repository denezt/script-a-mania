
# Remove unused partitions
for f in $(sudo fdisk -l /dev/loop* | egrep '2 GiB' | awk '{print $2}' | grep 'loop'); do printf "$f\n" | tr -d ':' | xargs sudo partx -d ;done
