#!/usr/bin/env bash

function add {
	if [[ -z "$2" ]]; then
		echo "Error: Missing GitHub username."
		echo "Usage: repojump add username"
		exit 1
	fi

	if ! cd ~/repojump; then
		mkdir ~/repojump
		cd ~/repojump
	fi

	if [[ "$2" == https://github.com/* ]]; then
		username=$(basename "$2")
	else
		username="$2"
	fi

	mkdir -p "$username"
	cd "$username"
	listfile=".$username.list"

	config_file="$HOME/repojump/configs/$username.config"

	if [[ -f "$config_file" ]]; then
		source "$config_file"
		curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/repos | \
		grep '"clone_url"' | \
		cut -d '"' -f 4 > "$listfile"
		echo "✅ Repo list for '$username' created (including private repos)."
	else
		curl -s https://api.github.com/users/$username/repos | \
		grep '"clone_url"' | \
		cut -d '"' -f 4 > "$listfile"
		echo "✅ Repo list for '$username' created (public repos only)."
		echo "👉 To include private repos, run:"
		echo "   repojump set-token $username <your_token>"
		echo "   and then run:"
		echo "   repojump add $username"
	fi
}

function set-token {
	if [[ -z "$2" || -z "$3" ]]; then
		echo "Error: Missing username or token."
		echo "Usage: repojump set-token username token"
		echo ""
		echo "To generate a GitHub personal access token:"
		echo "1. Go to https://github.com/settings/tokens"
		echo "2. Click 'Generate new token (classic)'"
		echo "3. Select scope: repo"
		echo "4. Generate and copy the token"
		exit 1
	fi

	config_dir="$HOME/repojump/configs"
	mkdir -p "$config_dir"
	config_file="$config_dir/$2.config"

	echo "GITHUB_USER=$2" > "$config_file"
	echo "GITHUB_TOKEN=$3" >> "$config_file"
	chmod 600 "$config_file"
	echo "Token and username saved to $config_file"
}

function help {
	echo "help text"
}

if [[ "$1" == "help" ]]; then
	help
elif [[ "$1" == "add" ]]; then
	add "$@"
elif [[ "$1" == "set-token" ]]; then
	set-token "$@"
else
	found=0
	for listfile in ~/repojump/*/.*.list; do
		if grep -q "/$1\.git" "$listfile"; then
			username=$(basename "$(dirname "$listfile")")
			repo_dir="$HOME/repojump/$username/$1"
			if [[ ! -d "$repo_dir" ]]; then
				echo "Cloning $1..."
				git clone "https://github.com/$username/$1.git" "$repo_dir"
			fi
			cd "$repo_dir"
			echo "✅ Entered directory: $repo_dir"
			found=1
			break
		fi
	done

	if [[ $found -eq 0 ]]; then
		echo "Error: Repo '$1' not found in any list."
		exit 1
	fi
fi
