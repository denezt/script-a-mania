printf "Stopping, Execution!!! ;-P"
exit 0; # DON'T RUN ALL OF THESE COMMANDS
size=1 ; while ! stat conn.log ; do echo $size ; bro -e "redef encap_hdr_size=$size;" -r network-dump.pcap ; size=$((size+1)) ; done # Keep i
pdf2txt cv.pdf | grep -C3 -i phone
for i in IMG_3[0-4]*.JPG ; do convert -quality 60 -geometry 300 "$i" "thumbs/$i" ; done # Make thumbnails of images IMG_3000.JPG - IMG_3499.JPG
rsync -a -delete empty/ foo/ # Apparently the fastest way to delete millions of small files
vim scp://user@server1//etc/httpd/httpd.conf
pv bigdump.sql.gz | gunzip | mysql
ps aux | awk '{if ($8=="Z") { print $2 }}'
cat longdomainlist.txt | rev | sort | rev
lsof -Pan -i tcp -i udp
# Show first lines (10 lines by default) of the specified file or stdin to the screen
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head 
while [[ $(date +%Y) -ne 2019 ]]; do figlet $(($(date -d 2019-01-01 +%s)-$(date +%s)));sleep 1;clear;done;figlet 'Happy New Year!' #countdown
rename 's/ /_/g' *
curl -s http://artscene.textfiles\.com/vt100/globe.vt | pv -L9600 -q
printf "%080d" | tr 0 n # Makes a Row of 'n' chars
perl -e 'print "n" x 80' # Makes a Row of 'n' chars
sudo dd if=/dev/sdc bs=1M skip=25k | strings -n12 # Start searching for text data, but skip the first 25GB (25k of 1MB blocks) of the drive.
echo "0987654321abcdefghijklmnopqrstuvwxyz" | sed 's/.\{4\}/& /g'
history | tr -cs "[:alpha:]" "\n" | sort | uniq -c | sort -rn | head
apt-get -y install language-pack-en-base
locale --all
locale-gen en_US.UTF-8
python3 -c 'import wx; a=wx.App(); wx.Frame(None, title="wxPython Frame").Show(); a.MainLoop()'
printf "192.168.0.1" | tr '.' ' ' | awk '{printf $4 }'
#Grepping for MAC addresses:
grep -E -o '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}' filename
# Making file immutable
sudo chattr +i /mydirectory/myfile
sudo chattr +i -V /mydirectory/myfile
lsattr /mydirectory/myfile
# Removing file immutable status
sudo chattr -i /mydirectory/myfile
sudo chattr -i -V /mydirectory/myfile
lsattr /mydirectory/myfile
# Making files immutable (Recursively)
sudo chattr +i -RV /mydirectory
sudo chattr +i -V /backups/passwd
# Removing files immutable status (Recursively)
sudo chattr -i -RV /mydirectory
sudo chattr -i -V /backups/passwd
# Get Easy To Read CPU Usage
cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf "%.2f\n", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}'
<?php
  $uploaddir = '/var/www/uploads/';
  $uploadfile = $uploaddir . basename($_FILES['userfile']['name']);
  echo '<pre>';
  if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile)) {
    echo "File is valid, and was successfully uploaded.\n";
  } else {
    echo "Possible file upload attack!\n";
  }
  echo 'Here is some more debugging info:';
  print_r($_FILES);
  print "</pre>";
?>
# View POST Packages
tcpdump -i wlan0 -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504F5354'
# View GET Packages
tcpdump -i wlan0 -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'
tcpdump -i enp0s8 -s 0 -A 'tcp dst port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'

nmap --open -p T:22 192.168.1.0/24 # Scan your internal home network for hosts listening on TCP port 22 (SSH protocol).
diff <(grep = config.txt) <(grep = config.txt-new) # Compare just the assignment lines of two config files that use = for value assignment.
# Main Git credentials for one year
git config --global credential.helper 'cache --timeout=31536000'

# Use the */ trick to get only the directories, then use ${dir%/} to remove the trailing / from each instance of $dir
for dir in */ ; do echo "${dir%/}" ; done 
# Get only the File Names
find ./dir1 -type f -exec basename {} \;
#  search and display a short man page description of a command/program 
apropos adduser
# Displaying machine architecture or hardware name
arch
# protocol that maps IP network addresses of a network neighbor with the hardware (MAC) addresses in an IPv4 network
apt-get -y install arp-scan
arp-scan --interface=eth0 --localnet
# Shutdown the system at 00:00 today or midnight
sudo echo "shutdown -h now" | at -m 00:00
# Query to see all current scheduled tasks
atq
# Remove first task
atrm 1
# Returns only the filename i.e. UsingTempFile
basename -s .java script-a-mania/UsingTempFile.java
# commandline arbitrary precision calculator language
echo "sqrt(20.9 + 15.00) * (8^7)/9" | bc
# Compress file
bzip2 -z filename
# Decompress file
bzip2 -d filename.bz2
# display the CRC checksum and byte count of a file
cksum results.csv
# Performs a byte-by-byte comparison of two files
cmp file1.txt file2.txt
# Compare two sorted files line-by-line
comm file1.txt file2.txt
# Sets System Date
date --set="8 JUN 2017 13:00:00"
# Copying files, converting and formatting according to flags provided on the command line.
# It can strip headers, extracting parts of binary files 
dd if=/home/tecmint/linux-1.0.1-i386.iso of=/dev/sdc1 bs=512M; sync
# Compare two files line by line
diff file1.txt file2.txt
# Retrieving hardware information of any Linux system
dmidecode --type system
# Calculates an expression 
expr 10 + 20 + 30
#Shows the prime factors of a number
factor 10
# Displays all the names of groups a user is a part of
groups myusername
# Compress a file, replacing it with one having a .gz extension.
cat file1 file2 | gzip > foogazi.gz
# Uncompress .gz file
gunzip foogazi.gz
# Print the system hostname and any related settings
hostnamectl
# Modify the system hostname
hostnamectl set-hostname [NEW_HOSTNAME]
# Probe for the hardware present in a Linux system
apt install hwinfo
hwinfo
# shows user and group information for the current user or specified username
id root
id myusername
# Display or manage routing, devices, policy routing and tunnels.
# Replaces the ifconfig program
ip addr add 192.168.56.10 dev eth1
# Check existing rules on a system 
iptables -L -n -v
# Manage wireless devices and their configuration
apt install iw
iw list
# Displays detailed wireless information from a wireless interface
iwlist wlp1s0 scanning
# Kill a process using its PID by sending a signal to it
kill -SIGTERM -p 9999
# List all currently loaded modules
kmod list
# Display a listing of last logged in users
last
# Create a soft link between files
ln -s /usr/bin/lscpu cpuinfo
# Find file with the basename 'index.php'
locate -b "index.php"
# Minimal tool to get detailed information on the hardware configuration of the machine
lshw 
# Displays information related to files opened by processes
lsof -u myusername
# View through relatively lengthy text files one screenful at a time
more myfile.txt
# Check if port 22 is opened
nc -zv garagebarge.com 22
# Shows the number of processing units present to the current process
nproc
# Create an archive of all files in the current directory
# and encrypt the contents of the archive file
tar -czf - * | openssl enc -e -aes256 -out backup.tar.gz
# Displays the process ID of a running program/command
pidof python3
# A powerful local/remote incremental backup script written in Python
suod apt -y install rdiff-backup
sudo rdiff-backup /etc /media/tecmint/Backup/server_etc.backup
# Rename many files at once
rename 's/\.html$/\.php/' *.html
# Create an archive and split into smaller
tar -cvjf myarchive.tar.bz2 /home/mydir/*
split -b 10M myarchive.tar.bz2 "myarchive.tar.bz2.part"
# Rejoining partitioned archives
cat myarchive.tar.bz2.parta* > myarchive.tar.gz.joined

# Show the checksum and block counts
sum myfile.txt 
# Concatenates and displays files in reverse
tac file.txt
# Shows how long the system has been running,
# number of logged on users and
# the system load averages as follows.
uptime
# Send a message to all users on the system
wall "Shutting, Down System soon!"
# Package and compress (archive) files -> Example 1
tar cf - . | zip | dd of=/dev/nrst0 obs=16k
# Package and compress (archive) files -> Example 2
zip inarchive.zip foo.c bar.c --out outarchive.zip
# Package and compress (archive) files -> Example 3
tar cf - .| zip backup -
# Quick access to files and directories in Linux
apt -y install fex-utils
# Save list of files/directories to clipboard
ls -a | zz
# Return data from clipboard
"zz"
clear;t=0;while [[ ! $t =~ ^\- ]] ; do printf "\e[0;0f" ; t=$( echo "1577836800-$(date +%s.%N)" | bc );echo $t|figlet -t -f smmono12 --metal; done;yes "$(seq 231 -1 16)" |while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done # Countdown to 50 years of Unix epoch time.
# Make local webserver available via remoteserver:8080.
# Req. GatewayPorts yes on sshd
ssh -R *:8080:localhost:80 remoteserver 

# Show Program Swap Status for all programs
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | grep 'kB' | less

# Show Swap usage of mysql daemon as kilobytes
for _pid in `pidof mysqld`; do grep --color VmSwap /proc/${_pid}/status; done
# Show Swap usage of mysql daemon as megabytes
for _pid in `pidof mysqld`; do grep --color VmSwap /proc/${_pid}/status | awk '{print $1,$2/1000"M"}'; done

# Tv Simulation
a=(22 28 34 40 46 47 48 49 );c=0;w=0;t=0;
while :;
do 
  printf "\e[0;0H";
  while [[ $t -le $LINES ]];
  do 
    for i in $(seq -s' ' 0 ${#a[*]});
    do 
      v=${a[$(((i+w+c-1)%(${#a[*]}+1)))]};
      printf "\e[48;5;${v}m\n";
      t=$[t+1];
    done;
    w=$[w+1];
  done;
  t=0;
  w=0;
  c=$[c+1];
  sleep 0.06;
done
# Disable No Password Access to mysql
# Input Manually
mysql -uroot
use mysql;
SHOW VARIABLES LIKE 'validate_password.%';
SET GLOBAL validate_password_policy=LOW;
SHOW VARIABLES LIKE 'validate_password%';
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

SELECT user,authentication_string,plugin,host FROM mysql.user;
# Remove Client from Fail2Ban Jail :-D
iptable -L -n
fail2ban-client set YOURJAILNAMEHERE unbanip IPADDRESSHERE
fail2ban-client set YOURJAILNAMEHERE banip IPADDRESSHERE
# Will Ban IP Address
fail2ban-client set sshd banip IPADDRESSHERE
# Will Unban IP Address
fail2ban-client set ssh unbanip IPADDRESSHERE

# Put the output of each tar file into its own directory.
for i in *.tar.gz; do mkdir "${i%.tar.gz}";( cd "${i%.tar.gz}" && tar zxvf ../"$i" );done 


# Finished !!

##################

##################
##  END OF CODE ##
##################
