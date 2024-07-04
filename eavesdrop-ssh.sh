# local is LINUX remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | aplay

# local is MAC OS remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | play -t raw -b 16 -c 2 -e signed-integer -r 44100 -
