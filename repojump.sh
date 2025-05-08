#!/usr/bin/env bash

function jump-to-repo {
	repo_name="$1"
	username=""
	duplicates=()

	for listfile in ~/repojump/*/.*.list; do
		if grep -q "$repo_name\.git" "$listfile"; then
			match_user=$(basename "$(dirname "$listfile")")
			duplicates+=("$match_user")
		fi
	done

	if [[ ${#duplicates[@]} -gt 1 ]]; then
		handle-duplicate-repo "$@"
		return
	fi

	for listfile in ~/repojump/*/.*.list; do
		if grep -q "$repo_name\.git" "$listfile"; then
			username=$(basename "$(dirname "$listfile")")
			break
		fi
	done

	if [[ -z "$username" ]]; then
		echo "❌ Error: Repo '$repo_name' not found in any list."
		return 1
	fi

	repo_dir="$HOME/repojump/$username/$repo_name"
	if [[ ! -d "$repo_dir" ]]; then
		echo "Cloning $repo_name from $username..."
		git clone "https://github.com/$username/$repo_name.git" "$repo_dir" || {
			echo "❌ Git clone failed."
			return 1
		}
	fi

	if cd "$repo_dir"; then
		echo "✅ Entered directory: $repo_dir"
	else
		echo "❌ Failed to enter directory: $repo_dir"
		return 1
	fi
}

function handle-duplicate-repo {
	repo_name="$1"
	requested_user="$2"

	if [[ -z "$requested_user" ]]; then
		echo "⚠️ Multiple users have a repo named '$repo_name'."
		echo "   Please run: repojump $repo_name <username>"
		return 1
	fi

	listfile="$HOME/repojump/$requested_user/.${requested_user}.list"
	if [[ ! -f "$listfile" ]]; then
		echo "❌ Error: No list found for user '$requested_user'."
		return 1
	fi

	if ! grep -q "$repo_name\.git" "$listfile"; then
		echo "❌ Error: Repo '$repo_name' not found under user '$requested_user'."
		return 1
	fi

	repo_dir="$HOME/repojump/$requested_user/$repo_name"
	if [[ ! -d "$repo_dir" ]]; then
		echo "Cloning $repo_name from $requested_user..."
		git clone "https://github.com/$requested_user/$repo_name.git" "$repo_dir" || {
			echo "❌ Git clone failed."
			return 1
		}
	fi

	if cd "$repo_dir"; then
		echo "✅ Entered directory: $repo_dir"
	else
		echo "❌ Failed to enter directory: $repo_dir"
		return 1
	fi
}

function add {
	if [[ -z "$2" ]]; then
		echo "Error: Missing GitHub username."
		echo "Usage: repojump add username"
		return 1
	fi

	if ! cd ~/repojump 2>/dev/null; then
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
	echo -n "" > "$listfile"

	config_file="$HOME/repojump/.configs/$username.config"

	if [[ -f "$config_file" ]]; then
		source "$config_file"
		api_url="https://api.github.com/users/$username/repos?per_page=100"
		auth_header="-H Authorization: token $GITHUB_TOKEN"
	else
		api_url="https://api.github.com/users/$username/repos?per_page=100"
		auth_header=""
	fi

	while [[ -n "$api_url" ]]; do
		echo "   Fetching: $api_url"

		if [[ -n "$GITHUB_TOKEN" ]]; then
			response=$(curl -sD - -H "Authorization: token $GITHUB_TOKEN" "$api_url")
		else
			response=$(curl -sD - "$api_url")
		fi
		body=$(echo "$response" | sed -n '/^\r$/,$p' | sed '1d')
		link_header=$(echo "$response" | grep -i '^Link:')

		if [[ -z "$body" ]]; then
			echo "❌ Error: Empty response body."
			break
		fi

		echo "$body" | grep '"clone_url"' | cut -d '"' -f 4 >> "$listfile"

		next_link=$(echo "$link_header" | grep -o '<[^>]*>; rel="next"' | sed -E 's/<([^>]+)>.*/\1/')

		if [[ -n "$next_link" ]]; then
			api_url="$next_link"
		else
			api_url=""
		fi
	done

	if [[ -f "$config_file" ]]; then
		echo "✅ Repo list for '$username' created (including private repos)."
	else
		echo "✅ Repo list for '$username' created (public repos only)."
		echo "   To include private repos, get a GitHub personal access token (PAT):"
		echo "    1. Visit https://github.com/settings/tokens"
		echo "    2. Click 'Generate new token' (classic) and select the 'repo' scope."
		echo "    3. Copy the token."
		echo "   Then run:"
		echo "   	repojump set-token $username <your_token>"
		echo "   and after that:"
		echo "   	repojump add $username"
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
		return 1
	fi

	config_dir="$HOME/repojump/.configs"
	mkdir -p "$config_dir"
	config_file="$config_dir/$2.config"

	echo "GITHUB_USER=$2" > "$config_file"
	echo "GITHUB_TOKEN=$3" >> "$config_file"
	chmod 600 "$config_file"
	echo "Token and username saved to $config_file"
}

function help {
	echo "📦 repojump — Manage and jump into GitHub repos easily"
	echo ""
	echo "Usage:"
	echo "  repojump add <GitHub-username>"
	echo "      → Fetch and store all repositories URLs for the given GitHub username."
	echo ""
	echo "  repojump set-token <username> <token>"
	echo "      → Store a GitHub personal access token (PAT) for a user to access private repos."
	echo ""
	echo "  repojump <reponame>"
	echo "      → Jump into the local folder of the given repo, cloning it if missing."
	echo ""
	echo "  repojump <reponame> <username>"
	echo "      → Jump into a specific user's repo when multiple users have repos with the same name."
	echo ""
	echo "Notes:"
	echo "  - Public repositories work without tokens."
	echo "  - Private repositories require running 'set-token' first."
	echo "  - All local clones are stored under: ~/repojump/<username>/<reponame>"
	echo "Uninstall:"
	echo "  To fully remove repojump and its data:"
	echo "    1. Delete the files: ~/.local/bin/repojump and ~/.local/bin/repojump_completion"
	echo "    2. Remove or comment the repojump setup lines from your ~/.bashrc or ~/.zshrc"
	echo "    3. (Warning) Delete all stored data and local clones with: rm -rf ~/repojump"
	echo "       → Caution: This will permanently erase any local changes or unpushed work."
	echo ""
	echo "  - This tool is open source, review the repository for implementation details."
}

function update {
	start_dir=$(pwd)

	for user_dir in ~/repojump/*; do
		if [[ -d "$user_dir" ]]; then
			username=$(basename "$user_dir")
			if [[ "$username" == ".configs" ]]; then
				continue
			fi
			echo "🔄 Updating $username..."

			if [[ "$username" == "$authenticated_username" ]]; then
				add "add" "$username"
			else
				add "add" "$username"
			fi
		fi
	done

	cd "$start_dir"
	echo "   All repositories updated."
}

if [[ "$1" == "help" ]]; then
	help
elif [[ "$1" == "add" ]]; then
	add "$@"
elif [[ "$1" == "set-token" ]]; then
	set-token "$@"
elif [[ "$1" == "update" ]]; then
	update
else
	jump-to-repo "$@"
fi
