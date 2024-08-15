# -----------------------------------------------
# Collect audio from remote microphone and play it locally

# local is MAC OS remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | play -t raw -b 16 -c 2 -e signed-integer -r 44100 -

# local is WINDOWS remote is LINUX
ssh -C pwn@pwn "arecord -f cd -" | ffmpeg -f s16le -ar 44100 -ac 2 -i - -f wav pipe:1 | ffplay -

# local is LINUX remote is LINUX:
ssh -C pwn@pwn "arecord -f cd -" | aplay

# LOCAL is LINUX remote is WINDOWS
ssh -C pwn@pwn "ffmpeg -f dshow -i audio='Microphone (Realtek High Definition Audio)' -f s16le -ar 44100 -ac 2 -" | aplay

# LOCAL is LINUX remote is MACOS
ssh -C pwn@pwn "rec -t raw -b 16 -c 2 -e signed-integer -r 44100 -" | aplay

# ---------------------------------------------
# Collect audio from local microphone and play it remotely

# local is MACOS remote is LINUX
rec -t raw -b 16 -c 2 -e signed-integer -r 44100 - | ssh -C pwn@pwn "aplay -f cd"

# local is WINDOWS remote is LINUX
ffmpeg -f dshow -i audio="Microphone (Realtek High Definition Audio)" -f s16le -ar 44100 -ac 2 - | ssh -C pwn@pwn "aplay -f cd"

# local is LINUX remote is LINUX
arecord -f cd - | ssh -C pwn@pwn "aplay"

# local is LINUX remote is WINDOWS
arecord -f cd - | ssh -C pwn@pwn "ffmpeg -f s16le -ar 44100 -ac 2 -i - -f wav pipe:1 | ffplay -"

# local is LINUX remote is MACOS
arecord -f cd - | ssh -C pwn@pwn "play -t raw -b 16 -c 2 -e signed-integer -r 44100 -"

# talk
while true; do read -p "Enter text to speak: " text; espeak -v "pl" -a 100 -s 60 "$text"; done
