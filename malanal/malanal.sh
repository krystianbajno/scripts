#!/bin/bash
# source malware_analysis.sh
# run_malware_analysis $tgtPath $resPath

patterns=("HKEY_LOCAL_MACHINE\\Software\\Microsoft" \
    "http[s]?://[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,6}" \
    "C:\\Windows\\System32")

get_url() {
    local DirectoryPath="${1:-/path/to/files}"
    local OutputPath="${2:-url_output.txt}"

    find "$DirectoryPath" -type f | while read -r file; do
        echo "Checking file for URLs: $file"
        results=$(strings "$file" | grep -E 'http[s]?://[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,6}')
        if [[ -n "$results" ]]; then
            echo "===== $file =====" >> "$OutputPath"
            echo "$results" >> "$OutputPath"
        fi
    done
}

get_sus() {
    local DirectoryPath="${1:-/path/to/files}"
    local OutputPath="${2:-suspicious_strings.txt}"

    find "$DirectoryPath" -type f | while read -r file; do
        echo "Analyzing file: $file"
        for pattern in "${patterns[@]}"; do
            matches=$(strings "$file" | grep -E "$pattern")
            if [[ -n "$matches" ]]; then
                echo "===== $file =====" >> "$OutputPath"
                echo "Pattern: $pattern" >> "$OutputPath"
                echo "$matches" >> "$OutputPath"
            fi
        done
    done
}

get_hash() {
    local DirectoryPath="${1:-/path/to/files}"
    local OutputPath="${2:-hash_output.txt}"

    find "$DirectoryPath" -type f | while read -r file; do
        echo "Hashing file: $file"
        hashMD5=$(md5sum "$file" | awk '{ print $1 }')
        hashSHA1=$(sha1sum "$file" | awk '{ print $1 }')
        hashSHA256=$(sha256sum "$file" | awk '{ print $1 }')

        echo "===== $file =====" >> "$OutputPath"
        echo "MD5: $hashMD5" >> "$OutputPath"
        echo "SHA-1: $hashSHA1" >> "$OutputPath"
        echo "SHA-256: $hashSHA256" >> "$OutputPath"
    done
}

get_ip() {
    local DirectoryPath="${1:-/path/to/files}"
    local OutputPath="${2:-ip_output.txt}"

    find "$DirectoryPath" -type f | while read -r file; do
        echo "Processing file: $file"
        results=$(strings "$file" | grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
        if [[ -n "$results" ]]; then
            echo "===== $file =====" >> "$OutputPath"
            echo "$results" >> "$OutputPath"
        fi
    done
}

get_dns() {
    local DirectoryPath="${1:-/path/to/files}"
    local OutputPath="${2:-dns_output.txt}"

    find "$DirectoryPath" -type f | while read -r file; do
        echo "Processing file: $file"
        results=$(strings "$file" | grep -E '[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,6}')
        if [[ -n "$results" ]]; then
            echo "===== $file =====" >> "$OutputPath"
            echo "$results" >> "$OutputPath"
        fi
    done
}

run_premalanal() {
    local TargetDirectory="${1:-/path/to/malware/samples}"
    local ResultsDirectory="${2:-/path/to/results}"

    if [[ ! -d "$TargetDirectory" ]]; then
        echo "Target directory not found: $TargetDirectory"
        return 1
    fi

    mkdir -p "$ResultsDirectory"
    
    local dnsOutputPath="$ResultsDirectory/dns_results.txt"
    local ipOutputPath="$ResultsDirectory/ip_results.txt"
    local hashOutputPath="$ResultsDirectory/hashes_results.txt"
    local suspiciousOutputPath="$ResultsDirectory/suspicious_results.txt"
    local urlOutputPath="$ResultsDirectory/url_results.txt"

    get_dns "$TargetDirectory" "$dnsOutputPath"
    get_ip "$TargetDirectory" "$ipOutputPath"
    get_hash "$TargetDirectory" "$hashOutputPath"
    get_sus "$TargetDirectory" "$suspiciousOutputPath"
    get_url "$TargetDirectory" "$urlOutputPath"

    echo "Malware analysis completed. Results saved in $ResultsDirectory."
}

# source malanal.sh
# run_premalanal $tgtPath $resPath