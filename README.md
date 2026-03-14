# 🦅 Elite Bug Bounty Toolkit

![license](https://img.shields.io/badge/license-MIT-blue)
![bash](https://img.shields.io/badge/language-bash-green)
![tools](https://img.shields.io/badge/tools-100+-orange)
![security](https://img.shields.io/badge/bugbounty-ready-red)

A **one-command installer** and **recon automation toolkit** for bug bounty hunters and penetration testers.

This project installs **100+ recon, fuzzing, and vulnerability discovery tools** and provides an **automated recon pipeline**.

---

# 🚀 Features

✔ Install **100+ bug bounty tools automatically**
✔ Automated **recon pipeline**
✔ Subdomain enumeration
✔ URL discovery & crawling
✔ Parameter discovery
✔ JS endpoint extraction
✔ Secret detection
✔ Directory brute forcing
✔ Vulnerability scanning with **Nuclei**
✔ Screenshot capture
✔ Organized recon output

---

# ⚡ Quick Install

Run directly:

```bash
bash <(curl -s https://raw.githubusercontent.com/ahmed7307/elite-bugbounty-installer/main/install_recon_elite.sh)
```

This will install:

* Go
* Python dependencies
* Wordlists
* Recon tools
* Vulnerability scanners

---

# 📦 Manual Installation

Clone repository:

```bash
git clone https://github.com/ahmed7307/elite-bugbounty-installer.git
cd elite-bugbounty-installer
```

Run installer:

```bash
chmod +x install_recon_elite.sh
./install_recon_elite.sh
```

---

# 🔎 Recon Pipeline

After installing tools you can run the automated recon framework.

```bash
chmod +x recon_pipeline.sh
./recon_pipeline.sh example.com
```

Example with options:

```bash
./recon_pipeline.sh example.com -o results -t 100
```

---

# 📂 Output Structure

Example output:

```
recon_example.com
 ├ subdomains
 ├ urls
 ├ params
 ├ js
 ├ screenshots
 ├ nuclei
 ├ alive_hosts.txt
 └ report.html
```

---

# 🛠 Installed Tool Categories

## Recon & Subdomain Discovery

* subfinder
* assetfinder
* amass
* dnsgen
* shuffledns
* puredns

---

## Crawlers & URL Collection

* katana
* gau
* waybackurls
* gospider
* hakrawler

---

## Fuzzing & Discovery

* ffuf
* feroxbuster
* dirsearch

---

## Vulnerability Scanning

* nuclei
* dalfox
* sqlmap
* XSStrike

---

## JavaScript Analysis

* LinkFinder
* SecretFinder
* subjs

---

## Secret Detection

* trufflehog
* regex secret scanner

---

# 🎯 Example Bug Bounty Workflow

```
target
 ↓
subdomain discovery
 ↓
alive hosts detection
 ↓
URL collection
 ↓
parameter discovery
 ↓
XSS / SQL testing
 ↓
directory fuzzing
 ↓
nuclei scan
 ↓
report
```

---

# 📌 Requirements

Linux / Kali / Ubuntu recommended.

Minimum requirements:

* Go
* Python3
* Git
* curl
* jq

---

# 🤝 Contributing

Pull requests are welcome.

You can contribute by:

* adding new recon tools
* improving automation
* improving reporting
* fixing bugs

---

# ⚠️ Disclaimer

This tool is intended for **authorized security testing and bug bounty programs only**.

The author is **not responsible for misuse** of this tool.
