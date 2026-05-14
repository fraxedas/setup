# Print the repo's default branch (origin/HEAD -> main -> master).
git config --global alias.default '!f() { DEF=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed ''s@^refs/remotes/origin/@@''); [ -z "$DEF" ] && git show-ref --verify --quiet refs/remotes/origin/main && DEF=main; [ -z "$DEF" ] && git show-ref --verify --quiet refs/remotes/origin/master && DEF=master; if [ -z "$DEF" ]; then echo "[!] Could not determine default branch (no origin/HEAD, no origin/main, no origin/master)." >&2; exit 1; fi; echo "$DEF"; }; f'

# git make <name>: create or switch to <user>/<name> and push with upstream tracking.
git config --global alias.make '!f() { PREFIX=$(git config user.email | cut -d@ -f1); BR="$PREFIX/$1"; if git rev-parse --verify "$BR" >/dev/null 2>&1; then echo "[>] Switching to existing branch: $BR"; git checkout "$BR"; else echo "[>] Creating and switching to new branch: $BR"; git checkout -b "$BR"; echo "[>] Pushing branch and setting upstream to origin/$BR"; git push -u origin "$BR"; fi; }; f'

# git get <branch>: fetch origin/<branch> and check it out with upstream tracking.
git config --global alias.get '!f() { BR="$1"; if [ -z "$BR" ]; then echo "Usage: git get <branch-name>"; exit 1; fi; echo "[>] Fetching origin/$BR..."; git fetch origin "$BR" && echo "[>] Checking out $BR and setting upstream..."; git checkout -b "$BR" --track "origin/$BR"; }; f'

# Rebase current branch onto the latest origin/<default>.
git config --global alias.rom '!f() { DEF=$(git default) || exit 1; BR=$(git rev-parse --abbrev-ref HEAD); echo "[*] Saving current branch: $BR"; git fetch origin && git checkout "$DEF" && git pull origin "$DEF" && git checkout "$BR" && echo "[>] Rebasing $BR onto origin/$DEF..."; git rebase "origin/$DEF"; }; f'

# Force-push the current branch with --force-with-lease (refuses on default).
git config --global alias.sync '!f() { DEF=$(git default 2>/dev/null); BR=$(git rev-parse --abbrev-ref HEAD); if [ -n "$DEF" ] && [ "$BR" = "$DEF" ]; then echo "[x] Refusing to force-push to $DEF."; exit 1; fi; echo "[>] Fetching latest from origin..."; git fetch origin "$BR" 2>/dev/null || echo "[!] $BR not on remote yet – skipping fetch."; echo "[>] Running: git push --force-with-lease origin $BR"; git push --force-with-lease origin "$BR"; }; f'

# Switch to default, pull, prune, then delete the previous branch.
git config --global alias.close '!f() { DEF=$(git default) || exit 1; BR=$(git rev-parse --abbrev-ref HEAD); if [ "$BR" != "$DEF" ]; then echo "[*] Current branch: $BR"; echo "[>] Switching to $DEF..."; git checkout "$DEF" && echo "[>] Pulling latest changes..."; git pull && echo "[>] Pruning remote-tracking branches..."; git fetch --prune && echo "[>] Deleting branch $BR..."; git branch -D "$BR"; else echo "[!] You are on $DEF – not deleting it."; fi; }; f'

# Delete all local branches starting with <user>/.
git config --global alias.clear '!f() { PREFIX=$(git config user.email | cut -d@ -f1); echo "[>] Finding branches starting with $PREFIX/..."; BRANCHES=$(git branch | grep "$PREFIX/" | sed "s/^[* ]*//"); if [ -z "$BRANCHES" ]; then echo "[!] No branches found starting with $PREFIX/"; else echo "[>] Deleting branches:"; echo "$BRANCHES"; echo "$BRANCHES" | xargs git branch -D; echo "[✓] Done!"; fi; }; f'

# Pretty single-line graph of all branches.
git config --global alias.lg 'log --graph --abbrev-commit --decorate --format=format:''%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'' --all'

# git top [from=YYYY-MM-DD] [until=YYYY-MM-DD] [count=N]: top contributors by commits.
git config --global alias.top '!f() { FROM=$(date +%Y-%m-01); UNTIL=""; COUNT=10; for arg in "$@"; do case $arg in from=*) FROM=${arg#*=} ;; until=*) UNTIL=${arg#*=} ;; count=*) COUNT=${arg#*=} ;; esac; done; echo "Git Top Contributors"; echo "From: $FROM  Until: ${UNTIL:-(now)}  Count: $COUNT"; UNTIL_ARG=; [ -n "$UNTIL" ] && UNTIL_ARG="--until=$UNTIL"; git log --since="$FROM" $UNTIL_ARG --format=''%an <%ae>'' | sort | uniq -c | sort -rn | head -n $COUNT | awk ''{ count=$1; $1=""; printf "%-5s %s\n", count, substr($0,2) }''; }; f'

# Print a random Star-Wars-themed testing quote.
git config --global alias.comment '!f() { comments=( ''These aren’t the failing tests you’re looking for – Obi-Wan Kenobi'' ''Test or test not. There is no skip – Yoda'' ''I find your lack of tests disturbing – Darth Vader'' ''May the tests be with you – Rebel Alliance'' ''It’s a test trap! – Admiral Ackbar'' ''Help me, tests. You’re my only hope – Princess Leia'' ''Only a Sith deals in skipped tests – Obi-Wan Kenobi'' ''The tests strike back – Narrator of the Saga'' ''Stay on target... with full test coverage – Gold Leader'' ''The tests are strong with this one – Darth Vader'' ''I am your tester – Darth Vader'' ''You were the chosen one! You were supposed to write the tests! – Obi-Wan Kenobi'' ''I’ve added more tests than a Death Star has stormtroopers – Han Solo'' ''The force is flaky with this test – Mace Windu'' ''This test is our only hope – Princess Leia'' ); count=${#comments[@]}; index=$((RANDOM % count)); echo "${comments[$index]}"; }; f'
