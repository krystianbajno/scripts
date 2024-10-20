cat /tmp/f | python3 server.py 2>&1 | nc -l 1337 > /tmp/f
