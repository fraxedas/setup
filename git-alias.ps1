git config --global alias.branch-name 'rev-parse --abbrev-ref HEAD'
git config --global alias.close-branch  '! [ $1 != master ] && echo cleaning branch $1 && git checkout master && git pull && git branch -d $1 '
git config --global alias.close  '! git close-branch $(git branch-name) '
git config --global alias.lg  "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
