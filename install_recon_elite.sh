#!/usr/bin/env bash

# ============================================================

# ELITE BUG BOUNTY INSTALLER

# installs recon + vuln + fuzzing tools automatically

# ============================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

GO_VERSION="1.22.0"
WORDLIST_DIR="$HOME/wordlists"
TOOLS_DIR="$HOME/tools"

mkdir -p $WORDLIST_DIR
mkdir -p $TOOLS_DIR
mkdir -p $HOME/go/bin

echo -e "${CYAN}===== Elite Bug Bounty Toolkit Installer =====${NC}"

# ------------------------------------------------

# INSTALL GO

# ------------------------------------------------

if ! command -v go &>/dev/null; then

echo -e "${YELLOW}Installing Go ${GO_VERSION}${NC}"

wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

fi

# ------------------------------------------------

# SYSTEM PACKAGES

# ------------------------------------------------

echo -e "${CYAN}Installing system packages${NC}"

sudo apt update

sudo apt install -y 
git curl wget jq unzip 
python3 python3-pip 
nmap dnsutils whois 
build-essential 
feroxbuster amass 
masscan

# ------------------------------------------------

# GO TOOL INSTALL FUNCTION

# ------------------------------------------------

install_go_tool(){

TOOL=$1
PKG=$2

if command -v $TOOL &>/dev/null; then

echo -e "${GREEN}$TOOL already installed${NC}"

else

echo -e "${CYAN}Installing $TOOL${NC}"
go install $PKG

fi

}

# ------------------------------------------------

# PROJECTDISCOVERY

# ------------------------------------------------

install_go_tool subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
install_go_tool httpx github.com/projectdiscovery/httpx/cmd/httpx@latest
install_go_tool katana github.com/projectdiscovery/katana/cmd/katana@latest
install_go_tool nuclei github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
install_go_tool naabu github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
install_go_tool dnsx github.com/projectdiscovery/dnsx/cmd/dnsx@latest
install_go_tool notify github.com/projectdiscovery/notify/cmd/notify@latest
install_go_tool interactsh-client github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
install_go_tool shuffledns github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
install_go_tool mapcidr github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest
install_go_tool alterx github.com/projectdiscovery/alterx/cmd/alterx@latest
install_go_tool tlsx github.com/projectdiscovery/tlsx/cmd/tlsx@latest

# ------------------------------------------------

# TOMNOMNOM

# ------------------------------------------------

install_go_tool waybackurls github.com/tomnomnom/waybackurls@latest
install_go_tool assetfinder github.com/tomnomnom/assetfinder@latest
install_go_tool gf github.com/tomnomnom/gf@latest
install_go_tool anew github.com/tomnomnom/anew@latest
install_go_tool qsreplace github.com/tomnomnom/qsreplace@latest
install_go_tool unfurl github.com/tomnomnom/unfurl@latest
install_go_tool httprobe github.com/tomnomnom/httprobe@latest

# ------------------------------------------------

# CRAWLING

# ------------------------------------------------

install_go_tool gau github.com/lc/gau/v2/cmd/gau@latest
install_go_tool gauplus github.com/bp0lr/gauplus@latest
install_go_tool gospider github.com/jaeles-project/gospider@latest
install_go_tool hakrawler github.com/hakluke/hakrawler@latest
install_go_tool cariddi github.com/edoardottt/cariddi/cmd/cariddi@latest

# ------------------------------------------------

# PARAM DISCOVERY

# ------------------------------------------------

install_go_tool arjun github.com/s0md3v/arjun@latest
install_go_tool uro github.com/s0md3v/uro@latest
install_go_tool dalfox github.com/hahwul/dalfox/v2@latest
install_go_tool kxss github.com/tomnomnom/hacks/kxss@latest
install_go_tool subjs github.com/lc/subjs@latest

# ------------------------------------------------

# DNS / SUBDOMAIN

# ------------------------------------------------

install_go_tool dnsgen github.com/ProjectAnte/dnsgen@latest
install_go_tool puredns github.com/d3mondev/puredns/v2@latest
install_go_tool hakrevdns github.com/hakluke/hakrevdns@latest
install_go_tool haklistdns github.com/hakluke/haklistdns@latest
install_go_tool gotator github.com/Josue87/gotator@latest

# ------------------------------------------------

# FUZZING

# ------------------------------------------------

install_go_tool ffuf github.com/ffuf/ffuf/v2@latest

# ------------------------------------------------

# SECRETS

# ------------------------------------------------

install_go_tool trufflehog github.com/trufflesecurity/trufflehog/v3/cmd/trufflehog@latest
install_go_tool mantra github.com/MrEmpy/mantra@latest

# ------------------------------------------------

# SCREENSHOTS

# ------------------------------------------------

install_go_tool gowitness github.com/sensepost/gowitness@latest

# ------------------------------------------------

# CLOUDFLARE / BYPASS

# ------------------------------------------------

install_go_tool cf-check github.com/dwisiswant0/cf-check@latest
install_go_tool subzy github.com/LukaSikic/subzy@latest

# ------------------------------------------------

# PYTHON TOOLS

# ------------------------------------------------

echo -e "${CYAN}Installing Python tools${NC}"

pip3 install arjun wafw00f sqlmap dirsearch

# ------------------------------------------------

# XSStrike

# ------------------------------------------------

if [ ! -d "$TOOLS_DIR/XSStrike" ]; then
cd $TOOLS_DIR
git clone https://github.com/s0md3v/XSStrike.git
fi

# ------------------------------------------------

# LinkFinder

# ------------------------------------------------

if [ ! -d "$TOOLS_DIR/LinkFinder" ]; then
cd $TOOLS_DIR
git clone https://github.com/GerbenJavado/LinkFinder.git
fi

# ------------------------------------------------

# SecretFinder

# ------------------------------------------------

if [ ! -d "$TOOLS_DIR/SecretFinder" ]; then
cd $TOOLS_DIR
git clone https://github.com/m4ll0k/SecretFinder.git
fi

# ------------------------------------------------

# JSFinder

# ------------------------------------------------

if [ ! -d "$TOOLS_DIR/JSFinder" ]; then
cd $TOOLS_DIR
git clone https://github.com/Threezh1/JSFinder.git
fi

# ------------------------------------------------

# WORDLISTS

# ------------------------------------------------

echo -e "${CYAN}Downloading wordlists${NC}"

cd $WORDLIST_DIR

if [ ! -d "SecLists" ]; then
git clone --depth 1 https://github.com/danielmiessler/SecLists.git
fi

wget -q https://raw.githubusercontent.com/six2dez/OneListForAll/main/onelistforallmicro.txt -O onelistforallmicro.txt

wget -q https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -O resolvers.txt

wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt -O subdomains.txt

# ------------------------------------------------

# GF PATTERNS

# ------------------------------------------------

mkdir -p ~/.gf

if [ ! -f ~/.gf/xss.json ]; then

git clone https://github.com/1ndianl33t/Gf-Patterns /tmp/gf-patterns

cp /tmp/gf-patterns/*.json ~/.gf/

fi

# ------------------------------------------------

# NUCLEI TEMPLATES

# ------------------------------------------------

echo -e "${CYAN}Updating nuclei templates${NC}"

nuclei -update-templates

# ------------------------------------------------

# DONE

# ------------------------------------------------

echo ""
echo -e "${GREEN}Installation Finished${NC}"

echo ""
echo "Try commands:"
echo "subfinder -d example.com"
echo "httpx -l targets.txt"
echo "nuclei -u https://example.com"

echo ""
echo "Wordlists:"
echo "$WORDLIST_DIR"

echo ""
echo "Reload shell:"
echo "source ~/.bashrc"
