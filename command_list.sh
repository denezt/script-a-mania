size=1 ; while ! stat conn.log ; do echo $size ; bro -e "redef encap_hdr_size=$size;" -r network-dump.pcap ; size=$((size+1)) ; done # Keep i
pdf2txt cv.pdf | grep -C3 -i phone
for i in IMG_3[0-4]*.JPG ; do convert -quality 60 -geometry 300 "$i" "thumbs/$i" ; done # Make thumbnails of images IMG_3000.JPG - IMG_3499.JPG
rsync -a -delete empty/ foo/ # Apparently the fastest way to delete millions of small files
vim scp://user@server1//etc/httpd/httpd.conf
pv bigdump.sql.gz | gunzip | mysql
ps aux | awk '{if ($8=="Z") { print $2 }}'
cat longdomainlist.txt | rev | sort | rev
lsof -Pan -i tcp -i udp
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
