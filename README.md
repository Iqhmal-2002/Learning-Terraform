# Learning Notes

My personal knowledge base. Synced between work laptop and personal laptop via git.

## The routine

**Start of a session:** `git pull`
**End of a session:** `git add -A && git commit -m "notes" && git push`

That's it. If I skip the pull, I get conflicts. If I skip the push, the other laptop is stale.

## Index

### Cheatsheets
- [git](cheatsheets/git.md) — the ~15 commands that cover 95% of daily use
- [linux-cli](cheatsheets/linux-cli.md) — navigating, finding, piping
- [docker](cheatsheets/docker.md) — containers, images, compose

### Logs
- [2026-08](logs/2026-08.md) — running journal, newest entry at top

### Snippets
- [snippets/](snippets/) — actual runnable scripts, not fenced code blocks

## Conventions

- One file per topic. Split when a file gets annoying to scroll (~300 lines).
- Logs are append-at-top: newest entry first, so I don't scroll to write.
- If I copy a command from a blog post, I write **why** it worked next to it.
  A command without context is a command I'll re-Google in three months.
- Anything I'd actually run more than twice becomes a script in `snippets/`.

## TODO

- [ ] Learn git properly (branches, rebase, what `HEAD` actually means)
- [ ] Add a cheatsheet for whatever I'm working on next
