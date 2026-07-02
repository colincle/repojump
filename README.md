# repojump

A command-line tool to track, fetch, and jump into GitHub repositories. It bulk
tracks a user's public or private repos, clones them on demand, and drops you
straight into their directories, which saves time when working across many
projects.

## Features

- Bulk fetch every repository URL for a given GitHub username.
- Track public repositories, and private ones with a personal access token.
- Jump into any tracked repo by name, cloning it automatically if it is missing.
- Disambiguate repos that share a name across different users.
- Update all tracked repository lists in one command.
- Works in both Bash and Zsh, with case-insensitive tab completion.

## Installation

```sh
git clone https://github.com/colincle/repojump_install.git
cd repojump_install
bash install.sh
source ~/.bashrc   # or: source ~/.zshrc
```

This installs the `repojump` command into `~/.local/bin/` and adds the PATH
entry, alias, and completion to your shell config. After installing, run
`repojump help` to confirm it works.

## Usage

Track every repository of a user:

```sh
repojump add <github-username>
```

Store a token so private repositories are included. The token is entered at a
hidden prompt, so it never appears in your shell history or process list:

```sh
repojump set-token <username>
```

Jump into a repository, cloning it if it is not present locally:

```sh
repojump <reponame>
```

When several tracked users have a repository with the same name, pick one:

```sh
repojump <reponame> <username>
```

Refresh every tracked user's repository list:

```sh
repojump update
```

Local clones live under `~/repojump/<username>/<reponame>`.

## Tokens and security

Public repositories work without authentication. Private repositories require a
GitHub personal access token with the `repo` scope, created at
`https://github.com/settings/tokens`.

The token is entered at a hidden prompt, never passed as a command-line argument,
so it stays out of your shell history and the process list. It is stored locally
in `~/repojump/.configs/<username>.config`, created with `600` permissions
(readable only by you), and is never transmitted anywhere except to GitHub over
HTTPS via `curl`.

## Uninstall

1. Delete the installed files:

   ```sh
   rm ~/.local/bin/repojump ~/.local/bin/repojump_completion
   ```

2. Remove the `repojump setup` block from `~/.bashrc` or `~/.zshrc`.

3. To also delete every stored list and local clone:

   ```sh
   rm -rf ~/repojump
   ```

   This permanently erases any local or unpushed work under that directory.

## License

MIT, see [LICENSE](LICENSE).
