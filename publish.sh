#!/usr/bin/env bash
csd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$csd"

git add .
git commit -m "update"
git branch -M main
git push -u origin main

curl https://raw.githubusercontent.com/superkeyor/ez.sh/main/ez.sh -o .ez.sh && mv -f .ez.sh ~/.ez.sh
source ~/.ez.sh

echo "Done."