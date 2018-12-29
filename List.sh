size=1 ; while ! stat conn.log ; do echo $size ; bro -e "redef encap_hdr_size=$size;" -r network-dump.pcap ; size=$((size+1)) ; done # Keep i
pdf2txt cv.pdf | grep -C3 -i phone
for i in IMG_3[0-4]*.JPG ; do convert -quality 60 -geometry 300 "$i" "thumbs/$i" ; done # Make thumbnails of images IMG_3000.JPG - IMG_3499.JPG
rsync -a -delete empty/ foo/ # Apparently the fastest way to delete millions of small files
vim scp://user@server1//etc/httpd/httpd.conf 
pv bigdump.sql.gz | gunzip | mysql
ps aux | awk '{if ($8=="Z") { print $2 }}' 
cat longdomainlist.txt | rev | sort | rev 
lsof -Pan -i tcp -i udp
while [[ $(date +%Y) -ne 2019 ]];do figlet $(($(date -d 2019-01-01 +%s)-$(date +%s)));sleep 1;clear;done;figlet 'Happy New Year!' #countdown
rename 's/ /_/g' *
curl -s http://artscene.textfiles\.com/vt100/globe.vt | pv -L9600 -q
