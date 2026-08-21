# Linux CLI

## Moving around

```bash
pwd                     # where am I
cd -                    # go back to previous directory (underrated)
ls -lah                 # long, all (incl. hidden), human-readable sizes
tree -L 2               # directory tree, 2 levels deep
```

## Finding things

```bash
find . -name "*.log"                 # by filename, recursive
find . -type f -mtime -1             # files modified in the last day
find . -type d -name node_modules    # directories only

grep -r "TODO" .                     # search file contents, recursive
grep -rn "TODO" .                    # ... with line numbers
grep -ri "todo" .                    # ... case-insensitive
grep -rn --include="*.py" "def " .   # limit to file type
```

`rg` (ripgrep) is faster and respects `.gitignore` — install it if you can:

```bash
rg "TODO"
rg -t py "def "
```

## Reading files

```bash
cat file.txt            # whole file
less file.txt           # paged; q to quit, / to search
head -20 file.txt       # first 20 lines
tail -20 file.txt       # last 20 lines
tail -f app.log         # follow a log as it's written  <-- the useful one
```

## Pipes and redirection

```bash
command > file          # write stdout to file (overwrites)
command >> file         # append
command 2> errors.txt   # redirect stderr only
command &> all.txt      # redirect both
command | grep foo      # pipe stdout into next command
command | tee file      # show output AND write it to a file
```

The mental model: every program has stdin (0), stdout (1), stderr (2). Pipes
connect one program's stdout to the next one's stdin. That's the whole idea.

## Text munging

```bash
wc -l file              # count lines
sort file | uniq -c     # count occurrences of each unique line
cut -d',' -f2 file.csv  # 2nd field, comma-delimited
sed 's/old/new/g' file  # find and replace (prints; -i edits in place)
awk '{print $1}' file   # first whitespace-separated column
```

## Processes

```bash
ps aux | grep node      # find a running process
kill <pid>              # ask it to stop (SIGTERM)
kill -9 <pid>           # force it (SIGKILL) — last resort
htop                    # interactive process viewer
lsof -i :3000           # what's using port 3000
```

## Permissions

```bash
chmod +x script.sh      # make executable
chmod 644 file          # rw-r--r--  (owner rw, everyone else read)
chmod 755 dir           # rwxr-xr-x  (typical for directories/scripts)
chown user:group file
```

The number is three digits: owner, group, others. 4=read, 2=write, 1=execute,
added together. So 7 = rwx, 6 = rw-, 5 = r-x.

## Disk and files

```bash
df -h                   # free space per mount
du -sh *                # size of each item in current dir
du -sh * | sort -h      # ... sorted
ncdu                    # interactive disk usage explorer
```

## Misc that saves time

```bash
!!                      # repeat last command
sudo !!                 # repeat last command with sudo
ctrl+r                  # search command history
history | grep docker   # find that command you ran last week
which python3           # where is this binary
man <command>           # the manual; /searchterm inside it
<command> --help        # usually faster than man
```
