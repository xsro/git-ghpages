#!/usr/bin/env bash
## ghpages <remoteurl> <branch> <folder> <dist>
## push 

project=$(dirname $0)

ARGS=`getopt -o Vd:c:: --long --version,dist:,branch:,message:,tag:,repo: -n "$0" -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi

echo ARGS=[$ARGS]
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"
echo formatted parameters=[$@]

while true
do
    case "$1" in
        -a|--along) 
            echo "Option a";
            shift
            ;;
        -b|--blong)
            echo "Option b, argument $2";
            shift 2
            ;;
        -c|--clong)
            case "$2" in
                "")
                    echo "Option c, no argument";
                    shift 2  
                    ;;
                *)
                    echo "Option c, argument $2";
                    shift 2;
                    ;;
            esac
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

#处理剩余的参数
echo remaining parameters=[$@]
echo \$1=[$1]
echo \$2=[$2]


# . $project/ghpages_core.sh



# remoteurl=$1
# branch=$2
# folder=$3
# dist=$4
# ignore_history=yes

# remoteurl="git@gitee.com:xsro/persue-master.git"
# branch="gh-pages"
# folder=$TMPDIR/$me
# dist=/Users/apple/repo/persue-master/build


# ghpages