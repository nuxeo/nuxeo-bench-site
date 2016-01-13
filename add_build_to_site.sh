#!/bin/bash -e
set -x
# This script add a CI build artifact of a bench to the bench reference site
cd $(dirname $0)
# fail on any command error


BUILD_PATH=$1
shift
SITE_PATH=$1
shift
DATA_FILE=$BUILD_PATH/archive/reports/data.yml
set -e

hugo_path=$(which hugo) || true
if [ -x "$hugo_path" ] ; then
  HUGO=hugo
else
  HUGO=/opt/build/tools/hugo/hugo
fi

function get_artifact_info() {
  # need dbprofile, benchid, benchname
  export BENCHID=`grep benchid $DATA_FILE | cut -d \: -f 2 | sed 's,[" ],,g'`
  export DBPROFILE=`grep dbprofile $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHNAME=`grep benchname $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
}

function copy_artifact() {
  mkdir -p $SITE_PATH/static/build/$BENCHID
  rm -rf $SITE_PATH/static/build/$BENCHID/$DBPROFILE
  cp -aLf $BUILD_PATH $SITE_PATH/static/build/$BENCHID/$DBPROFILE
  gzip $SITE_PATH/static/build/$BENCHID/$DBPROFILE/log || true
}

function add_data() {
  mkdir -p $SITE_PATH/data/bench
  cp -a $DATA_FILE $SITE_PATH/data/bench/$BENCHID$DBPROFILE.yml
  if [ -d $SITE_PATH/data_all ]; then
    # init data directory because hugo don't want a symlink for data directory
    cp -an $SITE_PATH/data_all/* $SITE_PATH/data/
    cp -a $DATA_FILE $SITE_PATH/data_all/bench/$BENCHID$DBPROFILE.yml
  fi
}

function add_content() {
  mkdir -p $SITE_PATH/content/bench/$BENCHID
  cat > $SITE_PATH/content/bench/$BENCHID/$DBPROFILE.md << EOF
---
dfile: "$BENCHID$DBPROFILE"
benchid: "$BENCHID"
benchname: "$BENCHNAME"
dbprofile: "$DBPROFILE"
type: bench
---
EOF
}

function rebuild_site() {
  pushd $SITE_PATH
  $HUGO --theme=hyde
  popd
}

# -------------------------------------------------------
# main
#
get_artifact_info
copy_artifact
add_data
add_content
rebuild_site
echo "Done"