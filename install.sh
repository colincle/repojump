#!/bin/bash

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# Make main script executable and copy it
chmod +x repojump.sh
cp repojump.sh "$HOME/.local/bin/repojump"

# Copy the completion script
cp repojump_completion "$HOME/.local/bin/repojump_completion"

# Prepare path, alias, and completion lines with comment
comment_line="# === repojump setup ==="
path_line='export PATH="$HOME/.local/bin:$PATH"'
alias_line='alias repojump="source $HOME/.local/bin/repojump"'
completion_line='source ~/.local/bin/repojump_completion'

# Update ~/.bashrc if exists
if [[ -f "$HOME/.bashrc" ]]; then
	if ! grep -Fxq "$comment_line" "$HOME/.bashrc"; then
		echo "" >> "$HOME/.bashrc"
		echo "$comment_line" >> "$HOME/.bashrc"
		echo "$path_line" >> "$HOME/.bashrc"
		echo "$alias_line" >> "$HOME/.bashrc"
		echo "$completion_line" >> "$HOME/.bashrc"
	fi
	echo "✅ Updated ~/.bashrc with PATH, alias, and completion."
fi

# Update ~/.zshrc if exists
if [[ -f "$HOME/.zshrc" ]]; then
	if ! grep -Fxq "$comment_line" "$HOME/.zshrc"; then
		echo "" >> "$HOME/.zshrc"
		echo "$comment_line" >> "$HOME/.zshrc"
		echo "$path_line" >> "$HOME/.zshrc"
		echo "$alias_line" >> "$HOME/.zshrc"
		echo "$completion_line" >> "$HOME/.zshrc"
	fi
	echo "✅ Updated ~/.zshrc with PATH, alias, and completion."
fi

echo ""
echo "✅ repojump installed to: $HOME/.local/bin/repojump"
echo "✅ repojump autocompletion installed to: $HOME/.local/bin/repojump_completion"
echo "⚠ Please run: source ~/.bashrc   and/or   source ~/.zshrc"
echo "   (depending on your shell) to apply the changes."
