## ghpages.sh

version="v0.0.1"

function remote_url(){
    cd $dist
    git config --get remote.$remote.url
    cd - >/dev/null
}

function set_default_value(){
    # options follow project https://github.com/tschaub/gh-pages
    # Base directory for all source files
    if [ -z $dist ]
    then dist="build"       
    fi
    # Name of the branch you are pushing to (default: "gh-pages")
    if [ -z $branch ]
    then branch="gh-pages"  
    fi
    # Commit message
    if [ -z $message ]
    then message="Updates"  
    fi
    # The name and email of the user, by default we use the user in the latest commit
    if [ -z $user_name ]
    then user_name=$(git log -1 --pretty=format:%an)
    fi
    if [ -z $user_email ]
    then user_email=$(git log -1 --pretty=format:%ae)
    fi
    # The name of the remote
    if [ -z $remote ]
    then remote="origin"    
    fi
    # Commit only (with no push)
    if [ -z $no_push ]
    then no_push=false      
    fi
    # Push force new commit without parent history
    if [ -z $no_history ]
    then no_history=false
    fi
    # add tag to commit
    if [ -z $tag ]
    then tag=""
    fi
    # URL of the repository you are pushing to
    if [ -z $repo ]
    then remoteurl=$(remote_url)
    else remoteurl=$repo
    fi

    # unsupported yet
    dest="."           #Target directory within the destination branch (relative to the root) (default: ".")
    add=false          #Only add, and never remove existing files
    git="git"          #Path to git executable
    dotfiles=false     #Include dotfiles
    depth=1            #depth for clone (default: 1)
    src="**/*"         #Pattern used to select which files to publish (default: "**/*")
    remove=""          #TODO:Remove files that match the given pattern (ignored if used together with --add). (default: ".")
    
    # additional options
    # the folder for store temporary files, will be inited as a git repository
    if [ -n $TMPDIR ]
    then folder=$TMPDIR/git_ghpages_$version
    else folder=/tmp/git_ghpages_$version
    fi
    remotename="git_ghpages"
    branchname="gp"

    log "push files in $dist to branch $branch of $remoteurl"
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

function ghpages(){
    set_default_value

    ghpages_temp_repository
    ghpages_temp_branch $remoteurl
    ghpages_copy_files $dist 

    msg=$(commit_message)
    cd $dest
    
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

if [ -z "$*" ]
then ghpages
fi