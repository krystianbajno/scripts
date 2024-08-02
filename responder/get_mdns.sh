for i in $(cat RESPONDER.LOG | grep -i -a mdns | cut -d ' ' -f 7); do nslookup $i >> MDNS_ASK; done
cat MDNS_ASK | cut -d '=' -f 2 | cut -d '.' -f 1 > MDNS_OUT
cat MDNS_OUT | sort | uniq
echo "MDNS COUNT: $(cat MDNS_OUT | sort | uniq | wc -l)" 
