#!/bin/bash -e
set -x
# This remove a bench from the reference site
cd $(dirname $0)
# fail on any command error
set -e
BUILD_PATH=$1
shift
SITE_PATH=$1
shift
DATA_FILE=$BUILD_PATH/archive/reports/data.yml

function get_artifact_info() {
  # need dbprofile, benchid, benchname
  export BENCHID=`grep benchid $DATA_FILE | cut -d \: -f 2 | sed 's,[" ],,g'`
  export DBPROFILE=`grep dbprofile $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHNAME=`grep benchname $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BUILDID=`grep build_number $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHFILE="$DBPROFILE$BUILDID"
}

function del_build() {
  rm -rf $SITE_PATH/static/build/$BENCHID/$BENCHFILE
  rm -f $SITE_PATH/data/bench/$BENCHID$BENCHFILE.yml || true
  rm -f $SITE_PATH/data_src/bench/$BENCHID$BENCHFILE.yml || true
  rm -f $SITE_PATH/content/bench/$BENCHID/$BENCHFILE.md
}

# -------------------------------------------------------
# main
#
get_artifact_info
del_build
echo "Done"