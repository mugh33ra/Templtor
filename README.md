
# 🛠️ Templtor

A bash-based automation tool designed to **clone multiple GitHub repositories**, **extract Nuclei templates**, and **organize CVE-related templates** in a structured format. The script is ideal for researchers, red teamers, or security enthusiasts working with [Nuclei](https://github.com/projectdiscovery/nuclei) templates.

---

## 🎯 Features

- 🚀 Automatically clones repositories from a list of GitHub URLs.
- 📁 Extracts all `.yaml` Nuclei templates and places them in `templates/`.
- 🔐 Filters CVE-related templates and moves them to `CVE-Templates/`.
- 🌀 Clean animated spinner to show real-time clone progress.
- 🧼 Cleans up unused cloned repositories after extraction.
- ❌ Handles `Ctrl+C` gracefully to skip current repo.

---

## 🧰 Requirements

- Bash
- Git
- `find`, `cp`, `mv`, and standard GNU utils

---

## 📦 Installation

Clone the repository or copy the script directly. Make it executable:

```bash
chmod +x templtor.sh
```

---

## 🚀 Usage

Update the repos.txt file for repository URLs (one per line):

```
https://github.com/projectdiscovery/fuzzing-templates.git
https://github.com/example/cve-templates.git
```

Then run:

```bash
./templtor.sh repos.txt
```

---

## 📁 Output Structure

```
script/
├── input_list.txt         # Your input file (copied here)
├── templates/             # All collected .yaml templates
└── CVE-Templates/         # Filtered templates matching CVE*
```

---

## ✨ Example Output

```
[✓] Cloned fuzzing-templates
   ↑ 127 templates
[✓] Cloned cve-templates
   ↑ 56 templates
[+] Collection complete
Total templates: 183
CVE templates:  56
```
## IMPORTANT NOTE:
```
if you want to copy all the cve templates to ~/nuclei-templates/http/cves just run the following it will do that. it will skip the existing templates and copy new CVE-Templates.
```
```bash
bash migration.sh
```
---

## 📌 Notes

- Repositories with existing folder names will have a counter suffix appended to avoid overwrites.
- Templates are only copied; original cloned repos are deleted after processing.
- Script ensures minimal disk usage and avoids clutter.

---

## 👨‍💻 Author

**mugh33ra**

- Twitter/X: [@mugh33ra](https://x.com/mugh33ra)
- GitHub: [github.com/mugh33ra](https://github.com/mugh33ra)
- linkedin [@ahmad-mugheera](https://www.linkedin.com/ahmad-mugheera)

---

## 📝 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT)
