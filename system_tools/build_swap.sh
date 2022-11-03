#!/usr/bin/env bash
# 
#
swapfile='/swapfile'

if [ -d "${swapfile}" ];
then
  dd if=/dev/zero of=${swapfile} bs=1024 count=1024288
  chown root:root ${swapfile}
  chmod 0600 ${swapfile}
  mkswap ${swapfile}
  swapon ${swapfile}
  _fstab=$(grep "${swapfile}" /etc/fstab)
  if [ -z "${_fstab}" ];
  then
    printf "${swapfile} none swap sw 0 0\n" > /etc/fstab
  fi
else
  printf "Warning: Swapfile ${swapfile} was already created!"
fi
