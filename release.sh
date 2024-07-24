#!/bin/sh

# MIT License
# 
# Copyright (c) 2021 Segment
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Original source: https://github.com/segmentio/analytics-swift/blob/main/release.sh

# check if `gh` tool is installed.
if ! command -v gh &> /dev/null
then
	echo "Github CLI tool is required, but could not be found."
	echo "Install it via: $ brew install gh"
	exit 1
fi

# check if `gh` tool has auth access.
# command will return non-zero if not auth'd.
authd=$(gh auth status -t)
if [[ $? != 0 ]]
then
	echo "ex: $ gh auth login"
	exit 1
fi

# check that we're on the `main` branch
branch=$(git rev-parse --abbrev-ref HEAD)
if [ $branch != 'main' ] && [[ $branch != release/* ]]
then
	echo "The 'main' must be the current branch to make a release."
	echo "You are currently on: $branch"
	exit 1
fi

if [ -n "$(git status --porcelain)" ]
then
  echo "There are uncommited changes. Please commit and create a pull request or stash them.";
  exit 1
fi

# find the latest semantic version from the git tags
version=$(git tag | head -1)
while read tagVersion
do
	if [ $(./scripts/semver.sh $tagVersion $version) == '1' ]
	then
		version=$tagVersion
	fi
done <<< "$(git tag)"

echo "Analytics-Swift Appcues current version: $version"

# no args, so give usage.
if [ $# -eq 0 ]
then
	echo "Release automation script"
	echo ""
	echo "Usage: $ ./release.sh <version>"
	echo "   ex: $ ./release.sh \"1.0.2\""
	exit 0
fi

newVersion="${1}"
echo "Preparing to release $newVersion..."

versionComparison=$(./scripts/semver.sh $newVersion $version)

if [ $versionComparison != '1' ]
then
	echo "New version must be greater than previous version ($version)."
	exit 1
fi

read -r -p "Are you sure you want to release $newVersion? [y/N] " response
case "$response" in
	[yY][eE][sS]|[yY])
		;;
	*)
		exit 1
		;;
esac

# get the commits since the last release, filtering ones that aren't relevant.
changelog=$(git log --pretty=format:"- [%as] %s (%h)" $(git describe --tags --abbrev=0 @^)..@ --abbrev=7 | sed '/[🔧🎬📸✅💡📝]/d')
tempFile=$(mktemp)
# write changelog to temp file.
echo "$changelog" >> $tempFile

cat $tempFile

# gh release will make both the tag and the release itself.
gh release create $newVersion -F $tempFile -t $newVersion

# remove the tempfile.
rm $tempFile
