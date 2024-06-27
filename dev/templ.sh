#!/bin/bash
set -euo pipefail

mkdir /tmp/templ

echo "running git clone"
git clone https://github.com/a-h/templ /tmp/templ --depth=1

echo "running get-version"
(cd /tmp/templ/get-version && sudo go run .) > /tmp/templ/.version
# Running go run . is required to prevent go from complaining about not having go.mod

echo "running go build"
cd /tmp/templ/cmd/templ && go build

echo "putting templ bin in /bin/"
mv /tmp/templ/cmd/templ/templ /bin
#       ^git      ^build  ^binary
