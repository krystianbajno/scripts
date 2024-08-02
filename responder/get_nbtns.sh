for i in $(cat RESPONDER.LOG | grep -i -a nbt-ns | cut -d ' ' -f 7); do nslookup $i >> NBTNS_ASK; done
cat NBTNS_ASK | cut -d '=' -f 2 | cut -d '.' -f 1 > NBTNS_OUT
cat NBTNS_OUT | sort | uniq
echo "NBT-NS count: $(cat NBTNS_OUT | sort | uniq | wc -l)"
