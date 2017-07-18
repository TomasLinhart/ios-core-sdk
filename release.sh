#!/bin/bash

function askForSure {
  while true; do
      read -p "Did you mean to release '$1' ? " yn
      case $yn in
          [Yy]* ) release $1 ; break;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}

function release {
  VERSION_NUMBER="$1"
  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Version tag already exist, exiting...\n"
      exit
  fi

  printf "Releasing version $VERSION_NUMBER\n";

  TEMPLATE="`cat CoreSDK.podspec.template`"
  PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
  printf "$PODSPEC" > CoreSDK.podspec

  git add CoreSDK.podspec
  git commit -m "chore(release): version set to $VERSION_NUMBER"
  git tag -a "$VERSION_NUMBER" -m "$VERSION_NUMBER"

  git push
  git push --tags

  pod spec lint --allow-warnings
  pod trunk push CoreSDK.podspec --allow-warnings

  printf "[$VERSION_NUMBER] released, go eat some cookies."
}

if [ -z $1 ]; then
  printf "USAGE: \r\n./release <version-number>\n";
  exit
else
  askForSure $1
fi
