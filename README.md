# 🧩 Leetcode Solutions

This repository contains my personal solutions to various **LeetCode** problems, organized by **difficulty** and written primarily in **Python**.  
Each file is named in the format:

```
<problem-number>-<problem-title>.py
```

For example:
```
13-roman-to-integer.py
73-set-matrix-zeroes.py
283-move-zeroes.py
```

---

## 📂 Repository Structure

```
Leetcode_Solutions/
│
├── git-sync.ps1           # PowerShell script for Windows auto-sync (pull → rename → commit → push)
├── git-sync.sh            # Bash script for macOS/Linux auto-sync
│
├── easy/                  # Easy-level problems
│   ├── 1-two-sum.py
│   ├── 13-roman-to-integer.py
│   └── ...
│
├── medium/                # Medium-level problems
│   ├── 73-set-matrix-zeroes.py
│   ├── 75-sort-colors.py
│   └── ...
│
├── hard/                  # Hard-level problems
│   ├── 124-binary-tree-maximum-path-sum.py
│   └── ...
│
└── annotate_leetcode.py   # Utility script to annotate files with LeetCode metadata
```

---

## ⚙️ Automation Tools

### 🪟 For Windows Users

Run the following to automatically:
- Rename new files into consistent format  
- Pull latest commits  
- Commit & push your work to GitHub  

```powershell
.\git-sync.ps1 "add new DP solutions"
```

If no message is given, it uses a timestamped message automatically.

> ⚠️ If you see a “script execution disabled” message, run this once:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

---

### 🐧 For macOS / Linux Users

Make the script executable once:
```bash
chmod +x git-sync.sh
```

Then use:
```bash
./git-sync.sh "add array problems"
```

If no message is provided, it creates a default one like:
```
chore: sync on 2025-10-15 08:30:00 UTC
```

---

## 🧠 File Annotation

Each solution file begins with metadata for easy reference and search:

```python
# LeetCode 73. Set Matrix Zeroes
# Difficulty: Medium
# Topics: Array, Matrix, Simulation
```

You can automatically insert or update these headers by running:
```bash
python annotate_leetcode.py
```

---

## 🌟 Future Plans

- [ ] Add topic auto-fetch via LeetCode API  
- [ ] Generate README sections dynamically with all solved problems  
- [ ] Add badges showing total problems solved by difficulty  

---

## 📜 License

This repository is for educational and personal practice purposes.  
All problems are © LeetCode and belong to their respective authors.
