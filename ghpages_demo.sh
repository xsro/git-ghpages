#!/usr/bin/env bash
mkdir build
date >build/index.txt

cd $(dirname $0)
curl -fsSL https://raw.githubusercontent.com/xsro/git-ghpages/main/ghpages_core.sh -o ./.ghpages.sh
. ./.ghpages.sh
rm ./.ghpages.sh
cd -

ignore_history=false
ghpages

