# Git

## The daily loop (this is 90% of it)

```bash
git pull                      # get changes from the other laptop FIRST
# ... do work ...
git add -A                    # stage everything changed
git commit -m "message"       # save a snapshot locally
git push                      # send it to GitHub
```

`git status` — run this constantly. It tells you what state you're in and
usually suggests the command you want next.

## First-time setup on a new machine

```bash
git config --global user.name "Iqhmal"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false      # merge on pull; simplest default
```

### Auth (do this properly once, save hours later)

SSH key per machine — generate a separate key on the work laptop and the
personal laptop. Never copy a private key between machines.

```bash
ssh-keygen -t ed25519 -C "work-laptop"
cat ~/.ssh/id_ed25519.pub        # paste into GitHub > Settings > SSH keys
ssh -T git@github.com            # test it
```

Then clone with the SSH URL (`git@github.com:user/repo.git`), not HTTPS.
If you cloned with HTTPS already:

```bash
git remote set-url origin git@github.com:user/repo.git
git remote -v                    # verify
```

## Starting a repo

```bash
git init
git add -A
git commit -m "initial commit"
git branch -M main
git remote add origin git@github.com:user/repo.git
git push -u origin main          # -u only needed the first time
```

## Looking at things

```bash
git status                       # what's changed / staged / untracked
git diff                         # unstaged changes
git diff --staged                # staged changes (what commit will contain)
git log --oneline -10            # last 10 commits, compact
git log --oneline --graph --all  # visual branch history
git show <hash>                  # what a specific commit changed
```

## Undoing things

Ordered from safest to scariest.

```bash
git restore <file>               # discard unstaged changes to one file
git restore --staged <file>      # unstage, but keep the changes
git commit --amend               # fix the last commit (message or contents)
                                 #   ONLY if you haven't pushed it yet
git revert <hash>                # make a NEW commit that undoes an old one
                                 #   safe on pushed history
git reset --soft HEAD~1          # undo last commit, keep changes staged
git reset --hard HEAD~1          # undo last commit, DELETE the changes
                                 #   this one actually loses work
```

Rule of thumb: `revert` for anything already pushed, `reset` only for local
commits nobody has seen.

## When the pull conflicts

Happens when you edited the same file on both laptops.

```bash
git pull
# CONFLICT (content): Merge conflict in cheatsheets/git.md
```

Open the file. You'll see:

```
<<<<<<< HEAD
what's on this laptop
=======
what came from the other laptop
>>>>>>> origin/main
```

Delete the markers, keep the text you want (often both), then:

```bash
git add <file>
git commit                       # completes the merge
git push
```

This is why notes live in markdown and not .docx — a binary conflict has no
readable middle.

## Branches (for later, but here's the shape)

```bash
git switch -c feature-name       # create + switch to a new branch
git switch main                  # go back
git merge feature-name           # bring the branch's work into main
git branch -d feature-name       # delete it once merged
```

## Things I keep forgetting

- `HEAD` = "where I am right now", usually the tip of the current branch.
- `origin` = the nickname for the GitHub remote. Not magic, just a name.
- `git add -A` stages deletions too; `git add .` in older git didn't. Use `-A`.
- A commit is a snapshot, not a diff. The diff is computed for display.
- `.gitignore` only ignores files git isn't already tracking. If you committed
  a file and then ignore it, it stays tracked until `git rm --cached <file>`.

## Panic button

```bash
git reflog                       # every position HEAD has been in, with hashes
git reset --hard <hash>          # go back to any of them
```

`reflog` is the reason a "lost" commit is almost never actually lost. It keeps
local history for ~90 days even for commits no branch points at.
