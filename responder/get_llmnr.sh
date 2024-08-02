for i in $(cat RESPONDER.LOG | grep -i -a llmnr | cut -d ' ' -f 8); do nslookup $i >> LLMNR_ASK; done
for i in $(cat RESPONDER.LOG | grep -i -a llmnr | cut -d ' ' -f 9); do nslookup $i >> LLMNR_ASK; done
cat LLMNR_ASK | cut -d '=' -f 2 | cut -d '.' -f 1 > LLMNR_OUT
cat LLMNR_OUT | sort | uniq
echo "LLMNR count: $(cat LLMNR_OUT | sort | uniq | wc -l)"
