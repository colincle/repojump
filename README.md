# repojump

**repojump** is a command-line tool to easily manage, fetch, and jump into GitHub repositories.  
It lets you bulk-track public or private repos, auto-clone them on demand, and jump right into their folders, saving you time when managing multiple projects.

---

## ✨ Features

- Bulk fetch all repos URLS from any GitHub username.
- Track both public and private repositories (with token).
- Jump into any local repo and auto-clone it if missing.
- Update all tracked repo lists in one command.
- Works with both Bash and zsh.

---

## 🚀 Installation

```
git clone https://github.com/yourusername/repojump.git
cd repojump
bash install.sh
source ~/.bashrc   # or source ~/.zshrc
```

This installs:
- `repojump` into `~/.local/bin/`
- shell aliases and autocompletion into your `.bashrc` or `.zshrc`

✅ After installation, run:
```
repojump help
```

---

## 📖 Usage

### Add all repos from a user
```
repojump add <GitHub-username>
```

### Add token for private repo access
```
repojump set-token <username> <your_personal_access_token>
```

### Jump into a repo (clones if missing)
```
repojump <reponame>
```

### Jump into a repo when multiple users have the same name
```
repojump <reponame> <username>
```

### Update all tracked users' repo lists
```
repojump update
```

---

## 🔒 Security Notice

- **Public repos** can be accessed without authentication.
- **Private repos** require a **GitHub personal access token (PAT)**.
- Tokens are stored locally in:
  ```
  ~/repojump/configs/<username>.config
  ```
  and are saved with `chmod 600` (user-only readable).

**Reminder:**  
This tool is fully open source. You can inspect the code to see exactly how tokens are handled.  
No tokens are transmitted or shared anywhere except directly to GitHub via secure `curl` requests.

---

## ❌ Uninstall

To fully remove **repojump** and its data:
1. Delete these files:
   ```
   ~/.local/bin/repojump
   ~/.local/bin/repojump_completion
   ```
2. Remove or comment the added lines in:
   ```
   ~/.bashrc or ~/.zshrc
   ```
3. ⚠️ (Warning) To delete all stored repos and local changes:
   ```
   rm -rf ~/repojump
   ```
   **This will permanently erase any unpushed or local work.**

---

## 🛠️ License & Contributions

This project is open source. Feel free to fork, improve, or adapt it.
