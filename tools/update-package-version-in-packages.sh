#!/usr/bin/env bash
cd "$(dirname "$0")/../"

get-package-version() {
  grep -oE '"version"\s*:\s*".*"' ./package.json | cut -d'"' -f4
}
get-gitpkg-repo() {
  sed -e '1,/"gitpkg": {/d' ./package.json | grep -oE '"registry"\s*:\s*".*"' | cut -d'"' -f4 | cut -d':' -f2
}

VERSION=$(get-package-version)
GITPKGREPO=$(get-gitpkg-repo)

for package_file in ./packages/*/package.json; do
  echo "Updating package version and dependencies in $package_file."
  sed -i 's/"version": ".*",/"version": "'$VERSION'",/g' $package_file
  sed -i --regexp-extended 's/"@sqorn\/(.*?)"\s*:\s*".*"/"@sqorn\/\1": "github:'${GITPKGREPO/\//\\/}'#sqorn-\1-v'$VERSION'-gitpkg"/' $package_file
done
