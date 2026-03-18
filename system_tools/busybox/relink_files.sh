#!/bin/bash

# OLDLNK="/usr/bin/busybox"
# NEWLNK="/usr/lib/initramfs-tools/bin/busybox"

OLDLNK="/usr/lib/initramfs-tools/bin/busybox"
NEWLNK="/bin/busybox"
COREUTILS="/usr/lib/cargo/bin/coreutils"


sudo ${OLDLNK} cp -a -v "${OLDLNK}" "${NEWLNK}"

# List of programs to relink
PRGLIST=( 'awk' 'chmod' 'cut' 'echo' 'egrep' 'ln' 'ls' 'read' 'rm' 'sh' 'sudo' )
for PRG in "${PRGLIST[@]}";
do
    echo "Relinking /bin/${PRG} to /bin/busybox"
    sudo ${OLDLNK} busybox ln -f -s /bin/busybox /bin/${PRG}
done

${OLDLNK} ls -l /bin | awk '{print $4,$5,$6}' | egrep 'busybox' | egrep -v "${NEWLNK}" | cut -d' ' -f1 | while read FILENAME; do
    if [ "${FILENAME}" != "busybox" ]; then
        echo "Relinking /bin/${FILENAME} to ${NEWLNK}"
        sudo ln -f -s "${NEWLNK}" "/bin/${FILENAME}"
        sudo chmod +x "/bin/${FILENAME}"
    else
        echo "Skipping busybox itself."
    fi
done
echo "Relinking complete."
# Set executable permissions
echo "Setting executable permissions for busybox-linked files in /usr/bin..."

# ${COREUTILS} ls -l /usr/bin | ${COREUTILS} awk '{print $4,$5,$6}' | ${COREUTILS} egrep 'busybox' | ${COREUTILS} cut -d' ' -f1 | while read FILENAME; do    
#     ${COREUTILS} ls -lsa "/usr/bin/${FILENAME}"
#     if [ -x "/usr/bin/${FILENAME}" ]; then
#         echo "/usr/bin/${FILENAME} is already executable. Skipping."
#         continue
#     fi
#     echo "Setting executable permission for /usr/bin/${FILENAME}"    
#     sudo ${OLDLNK} chmod +x "/usr/bin/${FILENAME}"
# done
# echo "Permission setting complete."



