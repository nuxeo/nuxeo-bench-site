#!/bin/bash -e
set -x
# This remove a bench from the reference site
cd $(dirname $0)
# defaults
HERE=`readlink -e .`
# fail on any command error
set -e

function help {
  echo "Usage: $0 BUILD_NUMBER"
  exit 0
}

function del_build() {
  git rm ./data/bench/$BUILD_NUMBER.yml ./content/*/$BUILD_NUMBER.md || true
  git commit -m"Removing build $BUILD_NUMBER"
  rm -f ./data/bench/$BUILD_NUMBER.yml ./content/*/$BUILD_NUMBER.md || true
}

# -------------------------------------------------------
# main
#
while getopts "h" opt; do
    case $opt in
        h)
            help
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))
BUILD_NUMBER=$1
shift

del_build
echo "Done"