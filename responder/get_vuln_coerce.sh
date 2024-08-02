#!/bin/sh
for line in $(cat RESPONDER2.LOG  | grep -a -i "Exception Happened" | cut -d "'" -f 2 | uniq); do
 nslookup $line >> vulnerableeee
done
