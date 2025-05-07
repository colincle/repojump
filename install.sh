#!/usr/bin/env bash
set -e

# === Pre-flight checks ===
[[ -f repojump.sh ]] || { echo "Error: repojump.sh not found. Aborting."; exit 1; }
[[ -f repojump_completion ]] || { echo "Error: repojump_completion not found. Aborting."; exit 1; }

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# Install main script and completion
install -m 755 repojump.sh "$HOME/.local/bin/repojump"
install -m 644 repojump_completion "$HOME/.local/bin/repojump_completion"

# Prepare path, alias, and completion lines with comment
comment_line="# === repojump setup ==="
path_line='export PATH="$HOME/.local/bin:$PATH"'
alias_line='alias repojump="source $HOME/.local/bin/repojump"'
completion_line='source ~/.local/bin/repojump_completion'

update_rc() {
	local rcfile="$1"
	if [[ -f "$rcfile" ]] && ! grep -Fxq "$comment_line" "$rcfile"; then
		{
			echo ""
			echo "$comment_line"
			echo "$path_line"
			echo "$alias_line"
			echo "$completion_line"
		} >> "$rcfile"
		echo "Updated $rcfile with PATH, alias, and completion."
	fi
}

# Update shells
update_rc "$HOME/.bashrc"
update_rc "$HOME/.zshrc"

echo ""
echo "✅ repojump installed to: $HOME/.local/bin/repojump"
echo ""
echo "⚠️ Please run: source ~/.bashrc   and/or   source ~/.zshrc (depending on your shell) to apply the changes."
echo ""
echo "🗑️  You can now delete the repojump_install repository."
echo "ℹ️  Need to uninstall? Run: repojump help"
