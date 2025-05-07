#!/bin/bash

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# Make script executable
chmod +x repojump.sh

# Copy and rename to 'repojump'
cp repojump.sh "$HOME/.local/bin/repojump"

# Prepare path and alias lines
path_line='export PATH="$HOME/.local/bin:$PATH"'
alias_line='alias repojump="source $HOME/.local/bin/repojump"'

# Update ~/.bashrc if exists
if [[ -f "$HOME/.bashrc" ]]; then
	if ! grep -Fxq "$path_line" "$HOME/.bashrc"; then
		echo "$path_line" >> "$HOME/.bashrc"
	fi
	if ! grep -Fxq "$alias_line" "$HOME/.bashrc"; then
		echo "$alias_line" >> "$HOME/.bashrc"
	fi
	echo "✅ Updated ~/.bashrc with PATH and alias."
fi

# Update ~/.zshrc if exists
if [[ -f "$HOME/.zshrc" ]]; then
	if ! grep -Fxq "$path_line" "$HOME/.zshrc"; then
		echo "$path_line" >> "$HOME/.zshrc"
	fi
	if ! grep -Fxq "$alias_line" "$HOME/.zshrc"; then
		echo "$alias_line" >> "$HOME/.zshrc"
	fi
	echo "✅ Updated ~/.zshrc with PATH and alias."
fi

echo ""
echo "✅ repojump installed to: $HOME/.local/bin/repojump"
echo "⚠ Please run: source ~/.bashrc   and/or   source ~/.zshrc"
echo "   (depending on your shell) to apply the changes."
