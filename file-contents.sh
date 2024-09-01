find . -type f -exec sh -c 'echo "===== {} ====="; cat "{}"; echo ""' \; | pbcopy
