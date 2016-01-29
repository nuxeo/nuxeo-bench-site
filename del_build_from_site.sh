#!/bin/bash -e
set -x
# This remove a bench from the reference site
cd $(dirname $0)
# defaults
HERE=`readlink -e .`
# fail on any command error
set -e

function help {
  echo "Usage: $0 SITE_PATH BUILD_NUMBER"
  exit 0
}

function search_build() {
  DATA_FILE=`grep -l "build_number: ${BUILD_ID}$" $SITE_PATH/data/bench/*.yml`
  if [ -z "$DATA_FILE" ]; then
    echo "No data file match build_number: $BUILD_ID"
    exit -1
  fi
  # need dbprofile, benchid, benchname
  export DBPROFILE=`grep dbprofile $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHNAME=`grep benchname $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHID=`grep benchid $DATA_FILE | cut -d \: -f 2 | sed 's,[" ],,g'`
  export BENCHFILE="$DBPROFILE$BUILD_ID"
  echo "## Found build_number $BUILD_ID: $DBPROFILE - $BENCHID - $BENCHNAME"
}

function del_build() {
  rm -rf $SITE_PATH/static/build/$BENCHID/$BENCHFILE
  rm -f $SITE_PATH/data/bench/$BENCHID$BENCHFILE.yml || true
  rm -f $SITE_PATH/content/*/$BENCHID/$BENCHFILE.md
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
SITE_PATH=$1
shift
BUILD_ID=$1
shift

search_build
del_build
echo "Done"