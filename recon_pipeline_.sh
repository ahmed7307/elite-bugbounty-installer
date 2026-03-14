#!/usr/bin/env bash

# =============================================

# RaptorX Recon Pipeline v4

# Automated Bug Bounty Recon Framework

# =============================================

TARGET=$1
OUT="recon_$TARGET"

mkdir -p $OUT
mkdir -p $OUT/subdomains
mkdir -p $OUT/urls
mkdir -p $OUT/params
mkdir -p $OUT/js
mkdir -p $OUT/screenshots
mkdir -p $OUT/nuclei

echo "Starting Recon on $TARGET"

# =============================================

# SUBDOMAIN ENUMERATION

# =============================================

echo "[+] Subdomain discovery"

subfinder -d $TARGET -silent >> $OUT/subdomains/subs.txt
assetfinder --subs-only $TARGET >> $OUT/subdomains/subs.txt
amass enum -passive -d $TARGET >> $OUT/subdomains/subs.txt

sort -u $OUT/subdomains/subs.txt > $OUT/subdomains/all_subs.txt

echo "[+] Total subdomains:"
wc -l $OUT/subdomains/all_subs.txt

# =============================================

# LIVE HOST DETECTION

# =============================================

echo "[+] Checking alive hosts"

httpx -l $OUT/subdomains/all_subs.txt -silent -threads 100 
-title -tech-detect -status-code 
-o $OUT/alive.txt

cat $OUT/alive.txt | awk '{print $1}' > $OUT/alive_hosts.txt

# =============================================

# URL COLLECTION

# =============================================

echo "[+] Collecting URLs"

gau --subs $TARGET >> $OUT/urls/urls.txt
waybackurls $TARGET >> $OUT/urls/urls.txt

cat $OUT/urls/urls.txt | uro > $OUT/urls/clean_urls.txt

# =============================================

# CRAWLING

# =============================================

echo "[+] Crawling targets"

katana -list $OUT/alive_hosts.txt -silent 
-depth 3 >> $OUT/urls/crawled.txt

cat $OUT/urls/crawled.txt >> $OUT/urls/clean_urls.txt

sort -u $OUT/urls/clean_urls.txt > $OUT/urls/all_urls.txt

# =============================================

# JS FILE EXTRACTION

# =============================================

echo "[+] Extracting JS files"

cat $OUT/urls/all_urls.txt 
| grep ".js" 
| sort -u > $OUT/js/js_files.txt

# =============================================

# JS ENDPOINT DISCOVERY

# =============================================

echo "[+] Extracting JS endpoints"

cat $OUT/js/js_files.txt 
| while read js; do
linkfinder -i $js -o cli >> $OUT/js/js_endpoints.txt
done

# =============================================

# PARAMETER DISCOVERY

# =============================================

echo "[+] Finding parameters"

cat $OUT/urls/all_urls.txt 
| grep "=" 
| sort -u > $OUT/params/params.txt

# =============================================

# XSS TESTING

# =============================================

echo "[+] XSS testing"

cat $OUT/params/params.txt 
| dalfox pipe > $OUT/xss_results.txt

# =============================================

# DIRECTORY FUZZING

# =============================================

echo "[+] Directory discovery"

cat $OUT/alive_hosts.txt 
| while read host; do
feroxbuster -u $host -q -t 40 -o $OUT/ferox_$(echo $host | sed 's/https?:////').txt
done

# =============================================

# SCREENSHOTS

# =============================================

echo "[+] Capturing screenshots"

gowitness file -f $OUT/alive_hosts.txt 
--destination $OUT/screenshots

# =============================================

# VULNERABILITY SCANNING

# =============================================

echo "[+] Running nuclei"

nuclei -l $OUT/alive_hosts.txt 
-severity medium,high,critical 
-o $OUT/nuclei/results.txt

# =============================================

# SUMMARY

# =============================================

echo ""
echo "Recon Completed"
echo "Subdomains:"
wc -l $OUT/subdomains/all_subs.txt

echo "Alive hosts:"
wc -l $OUT/alive_hosts.txt

echo "URLs:"
wc -l $OUT/urls/all_urls.txt

echo "Parameters:"
wc -l $OUT/params/params.txt

echo "JS Files:"
wc -l $OUT/js/js_files.txt

echo "Nuclei findings:"
wc -l $OUT/nuclei/results.txt
