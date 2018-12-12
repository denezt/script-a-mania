size=1 ; while ! stat conn.log ; do echo $size ; bro -e "redef encap_hdr_size=$size;" -r network-dump.pcap ; size=$((size+1)) ; done # Keep i
