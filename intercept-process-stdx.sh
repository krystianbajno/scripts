if [[ $# -lt 1 ]]; then
  echo "Usage: intercept.sh <pid>";
  exit
fi

strace -e trace=write -s1000 -fp $1 2>&1 \
| grep --line-buffered -o '".\+[^"]"' \
| grep --line-buffered -o '[^"]\+[^"]' \
| while read -r line; do
  printf "%b" $line;
done
