#!/bin/bash

commit_history=$(git log --pretty=format:"%H %cd" --date=local)

while read -r line; do
    commit_hash=$(echo $line | awk '{print $1}')
    commit_date=$(echo $line | awk '{$1=""; print $0}' | sed 's/^ *//')

    commit_day=$(date -d "$commit_date" +"%u")
    commit_hour=$(date -d "$commit_date" +"%H")
    commit_minute=$(date -d "$commit_date" +"%M")

    if [ "$commit_day" -ge 1 ] && [ "$commit_day" -le 5 ] && [ "$commit_hour" -ge 6 ] && [ "$commit_hour" -le 16 ] && ( [ "$commit_hour" -lt 16 ] || ( [ "$commit_hour" -eq 16 ] && [ "$commit_minute" -le 30 ] ) ); then
        echo "Commit: $commit_hash at $commit_date"
    fi
done <<< "$commit_history"
