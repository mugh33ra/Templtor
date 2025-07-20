#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color

# Show ASCII banner
show_banner() {
    echo -e "${YELLOW}"
    echo -e "     ╔╦╗┌─┐┌┬┐┌─┐┬ ╔╦╗┌─┐┬─┐"
    echo -e "      ║ ├┤ │││├─┘│  ║ │ │├┬┘"
    echo -e "      ╩ └─┘┴ ┴┴  ┴─┘╩ └─┘┴└─${NC}"
    echo -e "${BLUE}  N U C L E I   H A R V E S T E R"
    echo -e "${BLUE}----------------------------------"
    echo -e "${CYAN}       Coded By @mugh33ra"
    echo -e "      https://x.com/mugh33ra"
    echo -e "    https://github.com/mugh33ra${NC}\n"
}

# Spinner characters
spinner=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

# Global variables
current_dir=""
interrupted=false
spinner_pid=""

# Cleanup function
cleanup_repo() {
    if [[ -d "$current_dir" ]]; then
        echo -ne "\r${YELLOW}[!] Cleaning ${current_dir:0:15}...${NC}    "
        rm -rf "$current_dir"
        echo -e "\r${GREEN}[✓] Cleaned ${current_dir:0:15}${NC}     "
    fi
    [[ -f "temp" ]] && rm -f "temp"
    [[ -n "$spinner_pid" ]] && kill $spinner_pid 2>/dev/null
}

# Ctrl+C handler (skip current repo)
trap 'interrupted=true; cleanup_repo; echo -e "\r${RED}[✗] Skipped ${current_dir:0:15}${NC}"; continue' INT

# Spinner animation
spin() {
    local pid=$1
    local delay=0.1
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinner[@]}"; do
            echo -ne "\r${YELLOW}[$i]${NC} Cloning ${current_dir:0:15}..."
            sleep $delay
        done
    done
}

main() {
    show_banner
    
    file="$1"

    # Validate input
    [[ ! -f "$file" ]] && echo -e "${RED}Error: File '$file' not found${NC}" && exit 1

    # Setup workspace
    mkdir -p "templatess/templates" "templatess/CVE-Templates" || { echo -e "${RED}Failed to create directories${NC}"; exit 1; }
    cp "$file" "templatess/" && cd "templatess/" || { echo -e "${RED}Failed to prepare workspace${NC}"; exit 1; }

    # Process repositories
    while read -r link; do
        interrupted=false
        [[ -z "$link" ]] && continue

        # Generate clean directory name
        base_name=$(basename "$link" .git | tr -cd '[:alnum:]_-')
        current_dir="${base_name:0:25}"
        counter=1

        while [[ -d "$current_dir" ]]; do
            current_dir="${base_name:0:20}_${counter}"
            ((counter++))
        done

        # Clone with spinner
        (git clone -q "$link" "$current_dir" 2>/dev/null) &
        clone_pid=$!
        spin $clone_pid &
        spinner_pid=$!
        disown

        wait $clone_pid
        status=$?
        kill $spinner_pid 2>/dev/null

        if [[ $status -eq 0 ]]; then
            echo -e "\r${YELLOW}[✓] Cloned ${current_dir:0:15}${NC}     "

            # Process templates
            find "${current_dir}/" -name "*.yaml" -print > temp 2>/dev/null
            [[ -s "temp" ]] && count=$(wc -l < temp) || count=0
            while read -r template_path; do
                [[ -f "$template_path" ]] && cp "$template_path" "templates/"
            done < "temp"
            echo -e "   ${GREEN}↑ ${count} templates${NC}"

            # Move CVEs
            shopt -s nullglob
            mv -f templates/CVE* "CVE-Templates/" 2>/dev/null
            shopt -u nullglob

        else
            echo -e "\r${RED}[✗] Failed ${current_dir:0:15}${NC}     "
        fi

        cleanup_repo
        spinner_pid=""

    done < "$file"

    # Final report
    echo -e "\n${GREEN}[+] Collection complete${NC}"
    echo -e "Total templates: $(find templates -type f 2>/dev/null | wc -l)"
    echo -e "CVE templates:  $(find CVE-Templates -type f 2>/dev/null | wc -l)"
}

main "$@"
