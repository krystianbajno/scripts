find . -type f -exec sh -c 'echo "===== {} ====="; cat "{}"; echo ""' \; | pbcopy

Get-ChildItem -Recurse -File | ForEach-Object {
    Write-Output "===== $($_.FullName) ====="
    Get-Content $_.FullName
    Write-Output ""
} | Set-Clipboard
