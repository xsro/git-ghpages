#!/usr/bin/env bash
cd $(dirname $0)
. ./ghpages.sh
cd -

ignore_history=yes
cd /Users/apple/repo/persue-master
ghpages

