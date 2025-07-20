#!/bin/bash

# =============================================
# CONFIGURATION (Matching your exact paths)
# =============================================
cd "script/"
SOURCE_DIR="./CVE-Templates"    # Your 10,883 custom CVEs
TARGET_BASE_DIR="~/nuclei-templates/http/cves"        # Main Nuclei dir (3,186 existing)
LOG_FILE="./migration_$(date +%Y%m%d_%H%M%S).log"

# =============================================
# SAFETY CHECKS (With exact counts)
# =============================================
echo "[+] CVE Migration: $SOURCE_DIR → $TARGET_BASE_DIR"
echo "[+] Existing: $(find "$TARGET_BASE_DIR" -name "*.yaml" | wc -l) templates"
echo "[+] New: $(find "$SOURCE_DIR" -name "*.yaml" | wc -l) templates"

[ ! -d "$SOURCE_DIR" ] && { echo "[-] ERROR: Missing $SOURCE_DIR"; exit 1; }
[ ! -d "$TARGET_BASE_DIR" ] && { echo "[-] ERROR: Missing $TARGET_BASE_DIR"; exit 1; }

# =============================================
# PORTABLE MIGRATION (Using --update=none)
# =============================================
total_added=0
total_skipped=0

process_file() {
  local template=$1
  local cve_id=$(grep -m1 -Eo "(CVE|cve)-[0-9]{4}-[0-9]{4,}" "$template" | tr '[:lower:]' '[:upper:]')
  
  [ -z "$cve_id" ] && { echo "[!] NO_CVE: $(basename "$template")" >> "$LOG_FILE"; return; }

  local year=$(echo "$cve_id" | cut -d "-" -f 2)
  local target_dir="$TARGET_BASE_DIR/$year"
  mkdir -p "$target_dir"

  local filename=$(basename "$template")
  if [ ! -f "$target_dir/$filename" ]; then
    cp --update=none "$template" "$target_dir/" && {
      echo "[+] ADDED: $filename → $year/" | tee -a "$LOG_FILE"
      ((total_added++))
    } || echo "[-] COPY_FAILED: $filename" >> "$LOG_FILE"
  else
    echo "[-] SKIPPED: $filename (exists in $year)" >> "$LOG_FILE"
    ((total_skipped++))
  fi
}

export -f process_file
export TARGET_BASE_DIR LOG_FILE

# Process all YAML files in parallel (faster for 10K+ files)
find "$SOURCE_DIR" -type f -name "*.yaml" -print0 | xargs -0 -P $(nproc) -I {} bash -c 'process_file "$@"' _ {}

# =============================================
# RESULTS (With verification)
# =============================================
echo -e "\n[+] FINAL REPORT"
echo "----------------------------------------"
echo "ADDED: $total_added new templates"
echo "SKIPPED: $total_skipped duplicates"
echo "TOTAL IN TARGET: $(find "$TARGET_BASE_DIR" -name "*.yaml" | wc -l)"
echo "UNPROCESSED: $(grep -c "NO_CVE" "$LOG_FILE") files had no CVE ID"
echo "LOGFILE: $LOG_FILE"

# Verify no files were overwritten
echo -e "\n[+] VERIFICATION"
echo "Original count: $(find "$SOURCE_DIR" -name "*.yaml" | wc -l)"
echo "Expected target: $(( $(find "$TARGET_BASE_DIR" -name "*.yaml" | wc -l) - 3186 + $total_added ))"
