## ghpages.sh

version="v0.0.1"
me="git_ghpages_$version"
remotename=$me
branchname=$me

# options follow project https://github.com/tschaub/gh-pages
dist="build"       #Base directory for all source files
src="**/*"         #TODO: Pattern used to select which files to publish (default: "**/*")
branch="gh-pages"  #Name of the branch you are pushing to (default: "gh-pages")
dest="."           #TODO:Target directory within the destination branch (relative to the root) (default: ".")
add=no             #TODO:Only add, and never remove existing files
message="Updates"  #commit message
tag=""             #TODO:add tag to commit
git="git"          #Path to git executable
dotfiles=false     #TODO: Include dotfiles
repo=""            #URL of the repository you are pushing to
depth=1            #depth for clone (default: 1)
remote="origin"    #The name of the remote
user_name=""       #The name and email of the user
user_email=""
remove=""          #TODO:Remove files that match the given pattern (ignored if used together with --add). (default: ".")
no_push=false      #Commit only (with no push)
no_history=false   #Push force new commit without parent history

folder=$TMPDIR/$me

function remote_url(){
    if [ -z $repo ]
    then git config --get remote.$remote.url
    else echo $repo
    fi
}

#function to generate commit message
function commit_message(){
    cd $dist
    echo "$message $(git rev-parse HEAD)"
    cd - >/dev/null
}

#function to log infomation
function log(){
    echo $1
}

#make sure the temporary git repository folder exist
function ghpages_temp_repository(){
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
            if [ "$Select" = "A" ]
            then exit 1
            fi
            git init $folder
        fi
        cd -
    else
        mkdir -p $folder
        git init $folder
    fi
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
    if [ "$no_history" != "true" ]
    then
        git fetch $remotename $branch
        if [ $? -eq 0 ]
        then 
            git branch $branchname $remotename/$branch
            setup_branch=0
        fi
    fi
    if [ $setup_branch -eq 1 ]
    then git checkout --orphan $branchname
    fi
    git switch $branchname
    cd -
}

function ghpages_copy_files(){
    dist=$1
    for file in $(ls $folder)
    do 
    rm -rf $folder/$file
    done
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

    msg=$(commit_message)
    cd $dest
    if [ -z $user_name ]
    then user_name=$(git log -1 --pretty=format:%an)
    fi
    if [ -z $user_email ]
    then user_email=$(git log -1 --pretty=format:%ae)
    fi
    cd -
    cd $folder
    git add .
    git config --local user.name "$user_name"
    git config --local user.email "$user_email"
    git commit -m"$msg"
    if [ "$no_push" != "true" ]
    then
        if [ "$no_history" = "true" ]
            then git push -f  $remotename $branchname:$branch
            else git push  $remotename $branchname:$branch
        fi
    fi
    cd -
}