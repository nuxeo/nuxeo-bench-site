#!/bin/bash -e
set -x
# This script add a CI build artifact of a bench to the bench reference site
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

function copy_artifact() {
  mkdir -p $SITE_PATH/static/build/$BENCHID
  rm -rf $SITE_PATH/static/build/$BENCHID/$BENCHFILE
  cp -aLf $BUILD_PATH $SITE_PATH/static/build/$BENCHID/$BENCHFILE
  gzip $SITE_PATH/static/build/$BENCHID/$BENCHFILE/log || true
}

function add_data() {
  mkdir -p $SITE_PATH/data/bench
  cp -a $DATA_FILE $SITE_PATH/data/bench/$BENCHID$BENCHFILE.yml
  if [ -d $SITE_PATH/data_src ]; then
    # The data directory can not be symlink so we need to copy the persisted data from somewhere like data_src
    cp -an $SITE_PATH/data_src/* $SITE_PATH/data/
    cp -a $DATA_FILE $SITE_PATH/data_src/bench/$BENCHID$BENCHFILE.yml
  fi
}

function add_content() {
  mkdir -p $SITE_PATH/content/bench/$BENCHID
  cat > $SITE_PATH/content/bench/$BENCHID/$BENCHFILE.md << EOF
---
dfile: "$BENCHID$BENCHFILE"
benchid: "$BENCHID"
benchname: "$BENCHNAME"
dbprofile: "$DBPROFILE"
type: bench
---
EOF
}

# -------------------------------------------------------
# main
#
get_artifact_info
copy_artifact
add_data
add_content
echo "Done"