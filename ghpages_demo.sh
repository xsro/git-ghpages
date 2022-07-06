#!/usr/bin/env bash
mkdir -p build
date >build/index.txt

if [ "$1" != "ci" ]
then
    echo "test call from script" >>build/index.txt
    # Base directory for all source files
    export dist="test"
    # Name of the branch you are pushing to (default: "gh-pages")
    export branch=""
    # Commit message
    export message=""
    # The name and email of the user, by default we use the user in the latest commit
    export user_name=""
    export user_email=""
    # The name of the remote, the url of this remote will be read as `repo`
    export remote="" 
    # Push force new commit without parent history, default false
    export no_history=false
    # URL of the repository you are pushing to
    export repo=""
    cat ./ghpages_core.sh | bash -x
else
    echo "test call from script" >>build/index.txt
    export no_history=false
    export branch=test
    curl -fsSL https://raw.githubusercontent.com/xsro/git-ghpages/main/ghpages_core.sh | bash -x
fi

