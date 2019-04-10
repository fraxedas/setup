$current = $(git rev-parse --abbrev-ref HEAD)
git fetch
if ($current -ne 'master') {
    git checkout master
    git delete $current
}
git pull

