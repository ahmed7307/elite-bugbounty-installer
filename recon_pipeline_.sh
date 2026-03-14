#!/usr/bin/env bash
# =============================================
# RaptorX Recon Pipeline v4.1
# Automated Bug Bounty Recon Framework
# Fixed + Improved version
# Usage: ./raptorx_v4.sh target.com
# =============================================

set -uo pipefail

# ─────────────────────────────────────────────
# COLORS
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─────────────────────────────────────────────
# ARGS CHECK
# ─────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo -e "${RED}Usage: $0 <target.com>${NC}"
  exit 1
fi

TARGET="$1"
OUT="recon_${TARGET}"
START=$SECONDS

# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────
log_info()    { echo -e "${CYAN}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[-]${NC} $1"; }

# ─────────────────────────────────────────────
# SETUP DIRS
# ─────────────────────────────────────────────
mkdir -p "$OUT"/{subdomains,urls,params,js,screenshots,nuclei,ferox}

LOG="$OUT/recon.log"
echo "Started: $(date) | Target: $TARGET" > "$LOG"

echo -e "${CYAN}${BOLD}"
echo "  ██████╗  █████╗ ██████╗ ████████╗ ██████╗ ██████╗ ██╗  ██╗"
echo "  ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗╚██╗██╔╝"
echo "  ██████╔╝███████║██████╔╝   ██║   ██║   ██║██████╔╝ ╚███╔╝ "
echo "  ██╔══██╗██╔══██║██╔═══╝    ██║   ██║   ██║██╔══██╗ ██╔██╗ "
echo "  ██║  ██║██║  ██║██║        ██║   ╚██████╔╝██║  ██║██╔╝ ██╗"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
log_info "Target : ${BOLD}$TARGET${NC}"
log_info "Output : $OUT/"
log_info "Started: $(date)"

# ─────────────────────────────────────────────
# STAGE 1: SUBDOMAIN ENUMERATION
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 1 · Subdomain Enumeration${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "subfinder..."
subfinder -d "$TARGET" -silent \
  -o "$OUT/subdomains/subfinder.txt" 2>>"$LOG" || true

log_info "assetfinder..."
assetfinder --subs-only "$TARGET" \
  > "$OUT/subdomains/assetfinder.txt" 2>>"$LOG" || true

log_info "amass passive..."
amass enum -passive -d "$TARGET" \
  -o "$OUT/subdomains/amass.txt" 2>>"$LOG" || true

log_info "crt.sh..."
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" 2>/dev/null \
  | jq -r '.[].name_value' 2>/dev/null \
  | sed 's/\*\.//g' \
  | sort -u > "$OUT/subdomains/crtsh.txt" || true

# merge all
cat "$OUT/subdomains/"*.txt 2>/dev/null \
  | sort -u > "$OUT/subdomains/all_subs.txt"

log_success "Total subdomains: $(wc -l < "$OUT/subdomains/all_subs.txt")"

# ─────────────────────────────────────────────
# STAGE 2: ALIVE HOST DETECTION
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 2 · Alive Host Detection${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "httpx probing $(wc -l < "$OUT/subdomains/all_subs.txt") hosts..."

# FIX: httpx flags on single line - original had broken multiline
httpx -l "$OUT/subdomains/all_subs.txt" \
  -silent \
  -threads 100 \
  -title \
  -tech-detect \
  -status-code \
  -follow-redirects \
  -o "$OUT/alive.txt" \
  2>>"$LOG" || true

# FIX: extract clean URLs properly
grep -Eo 'https?://[^ ]+' "$OUT/alive.txt" \
  | sort -u > "$OUT/alive_hosts.txt" || true

log_success "Alive hosts: $(wc -l < "$OUT/alive_hosts.txt")"

# ─────────────────────────────────────────────
# STAGE 3: URL COLLECTION
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 3 · URL Collection${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "gau..."
gau --subs "$TARGET" --threads 10 2>>"$LOG" \
  | sort -u > "$OUT/urls/gau.txt" || true

log_info "waybackurls..."
waybackurls "$TARGET" 2>>"$LOG" \
  | sort -u > "$OUT/urls/wayback.txt" || true

cat "$OUT/urls/gau.txt" \
    "$OUT/urls/wayback.txt" \
    2>/dev/null | sort -u > "$OUT/urls/urls_raw.txt"

# FIX: uro might not be installed - fallback to sort -u
if command -v uro &>/dev/null; then
  cat "$OUT/urls/urls_raw.txt" | uro > "$OUT/urls/clean_urls.txt" || true
else
  log_warn "uro not found - using sort -u instead"
  cp "$OUT/urls/urls_raw.txt" "$OUT/urls/clean_urls.txt"
fi

log_success "URLs collected: $(wc -l < "$OUT/urls/clean_urls.txt")"

# ─────────────────────────────────────────────
# STAGE 4: CRAWLING
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 4 · Active Crawling (Katana)${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "katana crawling $(wc -l < "$OUT/alive_hosts.txt") hosts..."

# FIX: katana uses -list not -l, and flags on proper lines
katana \
  -list "$OUT/alive_hosts.txt" \
  -silent \
  -depth 3 \
  -jc \
  -iqp \
  -o "$OUT/urls/crawled.txt" \
  2>>"$LOG" || true

# merge all urls
cat "$OUT/urls/clean_urls.txt" \
    "$OUT/urls/crawled.txt" \
    2>/dev/null \
  | sort -u > "$OUT/urls/all_urls.txt"

log_success "Total URLs: $(wc -l < "$OUT/urls/all_urls.txt")"

# ─────────────────────────────────────────────
# STAGE 5: JS FILE EXTRACTION
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 5 · JS File Extraction${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# FIX: proper grep for JS files including query strings
grep -Eo 'https?://[^ ]+\.js([?#][^ ]*)?' \
  "$OUT/urls/all_urls.txt" 2>/dev/null \
  | sort -u > "$OUT/js/js_files.txt" || true

log_success "JS files: $(wc -l < "$OUT/js/js_files.txt")"

# ─────────────────────────────────────────────
# STAGE 6: JS ENDPOINT DISCOVERY
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 6 · JS Endpoint Discovery${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v linkfinder &>/dev/null; then
  log_info "linkfinder on $(wc -l < "$OUT/js/js_files.txt") JS files..."
  > "$OUT/js/js_endpoints.txt"

  # FIX: proper while read loop with IFS
  while IFS= read -r js; do
    [[ -z "$js" ]] && continue
    linkfinder -i "$js" -o cli \
      >> "$OUT/js/js_endpoints.txt" 2>>"$LOG" || true
  done < "$OUT/js/js_files.txt"

  log_success "JS endpoints: $(wc -l < "$OUT/js/js_endpoints.txt")"
else
  log_warn "linkfinder not found - skipping"
  touch "$OUT/js/js_endpoints.txt"
fi

# ─────────────────────────────────────────────
# STAGE 7: PARAMETER DISCOVERY
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 7 · Parameter Discovery${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# FIX: original used grep "=" which is too broad
# Better: grep proper URL param pattern
grep -Eo 'https?://[^ ]+\?[^ ]+' \
  "$OUT/urls/all_urls.txt" \
  | sort -u > "$OUT/params/params.txt" || true

# extract unique param names
grep -Eo '[?&][a-zA-Z0-9_-]+=?' \
  "$OUT/params/params.txt" \
  | sed 's/^[?&]//; s/=$//' \
  | sort -u > "$OUT/params/param_names.txt" || true

log_success "URLs with params : $(wc -l < "$OUT/params/params.txt")"
log_success "Unique param names: $(wc -l < "$OUT/params/param_names.txt")"

# GF patterns if available
if command -v gf &>/dev/null; then
  log_info "gf patterns..."
  cat "$OUT/params/params.txt" | gf xss \
    > "$OUT/params/gf_xss.txt" 2>/dev/null || true
  cat "$OUT/params/params.txt" | gf sqli \
    > "$OUT/params/gf_sqli.txt" 2>/dev/null || true
  cat "$OUT/params/params.txt" | gf ssrf \
    > "$OUT/params/gf_ssrf.txt" 2>/dev/null || true
  cat "$OUT/params/params.txt" | gf lfi \
    > "$OUT/params/gf_lfi.txt" 2>/dev/null || true
  cat "$OUT/params/params.txt" | gf redirect \
    > "$OUT/params/gf_redirect.txt" 2>/dev/null || true

  log_success "GF XSS     : $(wc -l < "$OUT/params/gf_xss.txt")"
  log_success "GF SQLi    : $(wc -l < "$OUT/params/gf_sqli.txt")"
  log_success "GF SSRF    : $(wc -l < "$OUT/params/gf_ssrf.txt")"
  log_success "GF LFI     : $(wc -l < "$OUT/params/gf_lfi.txt")"
  log_success "GF Redirect: $(wc -l < "$OUT/params/gf_redirect.txt")"
else
  log_warn "gf not found - skipping pattern matching"
fi

# ─────────────────────────────────────────────
# STAGE 8: XSS TESTING
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 8 · XSS Testing (Dalfox)${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v dalfox &>/dev/null; then
  XSS_INPUT="$OUT/params/params.txt"

  # use gf xss output if available (better targets)
  [[ -s "$OUT/params/gf_xss.txt" ]] && \
    XSS_INPUT="$OUT/params/gf_xss.txt"

  log_info "dalfox on $(wc -l < "$XSS_INPUT") URLs..."

  # FIX: dalfox pipe mode correct usage
  cat "$XSS_INPUT" \
    | dalfox pipe \
      --silence \
      --no-spinner \
      --output "$OUT/xss_results.txt" \
      2>>"$LOG" || true

  log_success "XSS results: $(wc -l < "$OUT/xss_results.txt" 2>/dev/null || echo 0)"
else
  log_warn "dalfox not found - skipping XSS"
fi

# ─────────────────────────────────────────────
# STAGE 9: DIRECTORY FUZZING
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 9 · Directory Fuzzing (Feroxbuster)${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

log_info "feroxbuster on $(wc -l < "$OUT/alive_hosts.txt") hosts..."

# FIX: original had broken sed regex and missing quotes
while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  # safe filename - FIX: proper sed escaping
  safe=$(echo "$host" | sed 's|https\?://||; s|[:/]|_|g')

  feroxbuster \
    -u "$host" \
    -q \
    -t 40 \
    -C 404,429,503 \
    --depth 2 \
    -x php,html,js,txt,json,bak,env \
    -o "$OUT/ferox/${safe}.txt" \
    2>>"$LOG" || true

done < "$OUT/alive_hosts.txt"

# merge ferox results
cat "$OUT/ferox/"*.txt 2>/dev/null \
  | grep -Eo 'https?://[^ ]+' \
  | sort -u > "$OUT/ferox_all.txt" || true

log_success "Ferox hits: $(wc -l < "$OUT/ferox_all.txt")"

# ─────────────────────────────────────────────
# STAGE 10: SCREENSHOTS
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 10 · Screenshots (Gowitness)${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v gowitness &>/dev/null; then
  log_info "gowitness screenshots..."

  # FIX: correct gowitness syntax
  gowitness file \
    -f "$OUT/alive_hosts.txt" \
    --destination "$OUT/screenshots/" \
    2>>"$LOG" || true

  log_success "Screenshots saved to $OUT/screenshots/"
else
  log_warn "gowitness not found - skipping"
fi

# ─────────────────────────────────────────────
# STAGE 11: NUCLEI SCAN
# ─────────────────────────────────────────────
echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  ▶ Stage 11 · Nuclei Vulnerability Scan${NC}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v nuclei &>/dev/null; then
  log_info "nuclei scanning..."

  # FIX: nuclei flags on proper lines, not broken across lines
  nuclei \
    -l "$OUT/alive_hosts.txt" \
    -severity medium,high,critical \
    -c 25 \
    -rl 50 \
    -o "$OUT/nuclei/results.txt" \
    -stats \
    2>>"$LOG" || true

  log_success "Nuclei findings: $(wc -l < "$OUT/nuclei/results.txt" 2>/dev/null || echo 0)"
else
  log_warn "nuclei not found - skipping"
fi

# ─────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────
ELAPSED=$(( SECONDS - START ))
MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║         RECON COMPLETE - SUMMARY         ║${NC}"
echo -e "${CYAN}${BOLD}╠══════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} Target     : ${BOLD}$TARGET${NC}"
echo -e "${CYAN}║${NC} Duration   : ${BOLD}${MINS}m ${SECS}s${NC}"
echo -e "${CYAN}║${NC} Output     : ${BOLD}$OUT/${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} Subdomains : $(wc -l < "$OUT/subdomains/all_subs.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} Alive hosts: $(wc -l < "$OUT/alive_hosts.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} Total URLs : $(wc -l < "$OUT/urls/all_urls.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} Params     : $(wc -l < "$OUT/params/params.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} JS Files   : $(wc -l < "$OUT/js/js_files.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} Ferox hits : $(wc -l < "$OUT/ferox_all.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} XSS found  : $(wc -l < "$OUT/xss_results.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}║${NC} Nuclei hits: $(wc -l < "$OUT/nuclei/results.txt" 2>/dev/null || echo 0)"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review  → $OUT/nuclei/results.txt"
echo "  2. Review  → $OUT/xss_results.txt"
echo "  3. Manual  → $OUT/params/gf_ssrf.txt"
echo "  4. Manual  → $OUT/params/gf_lfi.txt"
echo "  5. Manual  → $OUT/params/gf_redirect.txt"
echo ""
echo -e "${RED}⚠  Authorized targets only!${NC}"