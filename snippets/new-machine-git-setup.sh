#!/usr/bin/env bash
#
# new-machine-git-setup.sh
# Run once on a fresh laptop to configure git and generate an SSH key.
# Usage: ./new-machine-git-setup.sh "work-laptop"

set -euo pipefail

LABEL="${1:-$(hostname)}"
EMAIL="iqhmalworklife@gmail.com"
NAME="Iqhmal"

echo "==> Configuring git identity"
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "==> Handy aliases"
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --all -20"
git config --global alias.last "log -1 HEAD --stat"

KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$KEY" ]]; then
  echo "==> SSH key already exists at $KEY — skipping generation"
else
  echo "==> Generating SSH key labelled '$LABEL'"
  ssh-keygen -t ed25519 -C "$LABEL" -f "$KEY" -N ""
fi

echo
echo "==> Public key — add this at https://github.com/settings/keys"
echo
cat "${KEY}.pub"
echo
echo "==> Then test with:  ssh -T git@github.com"
