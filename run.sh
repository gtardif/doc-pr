#!/bin/sh

set -ex

CAPITALIZED_CHANNEL=$(echo $CHANNEL | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
if [ "${ARCH}" == "mac" ] ; then
	ARCH_LABEL="mac"
else
	ARCH_LABEL="windows"
fi

echo "Get sources"
git clone https://${GITHUB_TOKEN}@github.com/pinata-mac/docker.github.io.git sources
cd sources 
git remote add upstream https://${GITHUB_TOKEN}@github.com/docker/docker.github.io.git
git fetch upstream
git rebase upstream/master 
git push origin master
git checkout -b release_notes_${VERSION}
cd ..

wget https://download.docker.com/${ARCH}/${CHANNEL}/${BUILD_NUMBER}/NOTES
# delete all leading blank lines at top of file
sed -i '/./,$!d' NOTES
# delete all trailing blank lines at end of file
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}'  NOTES
#ad version header
sed -i '1s/^/\n'"### Docker Community Edition ${VERSION} 2017-08-31 (${CAPITALIZED_CHANNEL})"'\n\n/' NOTES
cat NOTES

#update docs
sed -i -e '/'"## ${CAPITALIZED_CHANNEL} Release Notes"'/r NOTES' "./sources/docker-for-${ARCH_LABEL}/release-notes.md"

grep -C 10 "## Edge Release Notes" ./sources/docker-for-windows/release-notes.md

cd sources
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_EMAIL}"

git commit -asm "Docker for ${ARCH_LABEL} ${CHANNEL} relnotes ${VERSION}"

git push origin release_notes_${VERSION}
hub pull-request -m "Release notes for ${VERSION} (${CAPITALIZED_CHANNEL})" -b "docker/docker.github.io:master"
