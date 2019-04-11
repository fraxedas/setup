git config --global alias.branch-name 'rev-parse --abbrev-ref HEAD'
git config --global alias.close-branch  '! [ $1 != master ] && git checkout master && git branch -d $1'
git config --global alias.close  '! git fetch && git close-branch $(git branch-name) '