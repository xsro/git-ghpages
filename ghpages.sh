## ghpages.sh

version="v0.0.1"
me="git_ghpages_$version"
remotename=$me
branchname=$me
folder=$TMPDIR/$me
ignore_history=no
dist="build"
branch="gh-pages"

function remote_url(){
    git config --get remote.origin.url
}

#function to generate commit message
function commit_message(){
    cd $dist
    message="deploy $(git rev-parse HEAD)"
    cd -
}

#function to log infomation
function log(){
    echo $1
}

#make sure the temporary git repository folder exist
function ghpages_temp_repository(){
    cd $folder
    if [ -d $folder ]
    then
        log "folder $folder is not empty, I run 'git status' here."
        git status
        if [ $? -eq 0 ]
        then
            log "this is a git repository, and it track following remotes"
            git remote -v
        else
            read -p "I will init this folder as git repository. press Y to continue, A to abort" Select
            if [ "$Select" = "A" ]
            then exit 1
            fi
            git init $folder
        fi
    else
        mkdir -p $folder
        git init $folder
    fi
    cd -
}

function ghpages_temp_branch(){
    cd $folder
    remoteurl=$1
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
    cd -
}

function ghpages_copy_files(){
    dist=$1
    git rm -rf .
    for file in $(ls $dist)
    do 
    cp -r $dist/$file $folder/
    done
}

function default_value(){
    empty_opt="_"
    if [ -z $1 ]
    then log "default folder $dist"
    else dist=$1
    fi

    if [ -z $2 ]
    then 
        remoteurl=$(remote_url)
        log "default remote $remoteurl"
    else remoteurl=$2
    fi

    if [ -z $3 ]
    then log "default branch $3"
    else branch=$3
    fi

    log "push files in $dist to branch $branch of $remoteurl"
}

function ghpages(){
    default_value

    ghpages_temp_repository
    ghpages_temp_branch $remoteurl
    ghpages_copy_files $dist 

    cd $folder
    git add .
    git commit -m"$(commit_message)"
    if [ "$ignore_history" = "yes" ]
    then git push -f  $remotename $branchname:$branch
    else git push  $remotename $branchname:$branch
    fi
    cd -
}


