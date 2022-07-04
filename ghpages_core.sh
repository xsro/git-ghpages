me="git_ghpages_$(cat $project/version)"
remotename=$me
branchname=$me

cd $dist
message="deploy $(git rev-parse HEAD)"
cd -

function log(){
    echo $1
}

function ghpages(){
    if [ -d $folder ]
    then
        cd $folder
        log "folder $folder is not empty, I run 'git status' here."
        git status
        if [ $? -eq 0 ]
        then
            log "this is a git repository, and it track following remotes"
            git remote -v
        else
            read -p "I will init this folder as git repository. press Y to continue, A to abort" Select
            if [ "$Select" == "A" ]
            then exit 1
            fi
            git init $folder
        fi
        cd -
    else
        mkdir -p $folder
        git init $folder
    fi

    cd $folder

    git remote add $remotename $remoteurl
    if [ $? -ne 0 ]
        then git remote set-url $remotename $remoteurl
    fi

    setup_branch=1
    git branch -M $branchname $(date "+%Y%m%d/%H-%M-%S")
    if [ "$ignore_history" != "yes" ]
    then
        git fetch $remotename $branch
        if [ $? -eq 0 ]
        then 
            git branch $branchname $remotename/$branch
            setup_branch=1
        fi
    fi

    if [ $setup_branch -eq 1 ]
    then git checkout --orphan $branchname
    fi

    git rm -rf .
    for file in $(ls $dist)
    do 
    cp -r $dist/$file $folder/
    done
    git add .
    git commit -m"$message"
    if [ "$ignore_history" == "yes" ]
    then git push -f  $remotename $branchname:$branch
    else git push  $remotename $branchname:$branch
    fi
    cd -
}

