#!/bin/sh

set -ex

CAPITALIZED_CHANNEL=$(echo $CHANNEL | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
if [ "${ARCH}" == "mac" ] ; then
	ARCH_LABEL="mac"
else
	ARCH_LABEL="windows"
fi

TODAY=$(date +'%Y-%m-%d')

wget https://download.docker.com/${ARCH}/${CHANNEL}/${BUILD_NUMBER}/NOTES
# delete all leading blank lines at top of file
sed -i '/./,$!d' NOTES
# delete all trailing blank lines at end of file
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}'  NOTES
#ad version header
sed -i '1s/^/\n'"### Docker Community Edition ${VERSION} ${TODAY} (${CAPITALIZED_CHANNEL})"'\n\n/' NOTES
cat NOTES

echo "Get sources"
git clone https://${GITHUB_TOKEN}@github.com/gtardif/docker.github.io.git sources
cd sources 
git remote add upstream https://${GITHUB_TOKEN}@github.com/docker/docker.github.io.git
git fetch upstream
git rebase upstream/master 
git push origin master
git checkout -b release_notes_${VERSION}
cd ..
#update docs
sed -i -e '/'"## ${CAPITALIZED_CHANNEL} Release Notes"'/r NOTES' "./sources/docker-for-${ARCH_LABEL}/release-notes.md"

grep -C 10 "## ${CAPITALIZED_CHANNEL} Release Notes" ./sources/docker-for-${ARCH_LABEL}/release-notes.md

cd sources
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_EMAIL}"

git commit -asm "Docker for ${ARCH_LABEL} ${CHANNEL} relnotes ${VERSION}"

git push origin release_notes_${VERSION}
hub pull-request -m "$(printf "Release notes for ${VERSION} (${CAPITALIZED_CHANNEL})\n\ncc @gbarr01, cc @mistyhacks")" -b "docker/docker.github.io:master"