# local is LINUX remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | aplay

# local is MAC OS remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | play -t raw -b 16 -c 2 -e signed-integer -r 44100 -

# talk
while true; do read -p "Enter text to speak: " text; espeak -v "pl" -a 100 -s 60 "$text"; done
