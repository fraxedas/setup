$repo = $Args[0]
Write-Output $repo
if($repo){
    Write-Output "Moving to: $repo"
    Set-Location $repo
}

$current = $(git rev-parse --abbrev-ref HEAD)
git fetch
if ($current -ne 'master') {
    git checkout master
    git pull
    git branch -d $current
}