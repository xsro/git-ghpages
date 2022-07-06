# `gh-pages` via shell script

This is a pure bash shell script to do something like `gh-pages`.
By use this script, we can publish a subfolder to a independent branch.

- [ ] currently cannot work in github action
- [ ] a better CLI is needed
- [ ] a powershell implement may helps more

## usage

The following script will publish all files in folder `build`
to the remote git repository as orphan branch `test`

```shell
echo "test call from script" >>build/index.txt
# Base directory for all source files
export dist="build"
# Name of the branch you are pushing to (default: "gh-pages")
export branch="test"
# Commit message
export message=""
# The name and email of the user, by default we use the user in the latest commit
export user_name=""
export user_email=""
# The name of the remote, the url of this remote will be read as `$repo`, default `origin`
export remote="" 
# URL of the repository you are pushing to, default the url of `$remote`
export repo=""
# Push force new commit without parent history, default false
export no_history=false

curl -fsSL https://raw.githubusercontent.com/xsro/git-ghpages/main/ghpages_core.sh | bash
```

For gitee user, we can use its service.

```
curl -fsSL https://gitee.com/xsro/git-ghpages/raw/main/ghpages_core.sh | bash
```

