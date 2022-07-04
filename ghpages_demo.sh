#!/usr/bin/env bash
mkdir -p build
date >build/index.txt

cd $(dirname $0)
if [ "$1" = "ci" ]
then
curl -fsSL https://raw.githubusercontent.com/xsro/git-ghpages/main/ghpages_core.sh -o ./.ghpages.sh
. ./.ghpages.sh
rm ./.ghpages.sh
else
. ./ghpages_core.sh
fi
cd -

no_history=false
branch="test"
ghpages

