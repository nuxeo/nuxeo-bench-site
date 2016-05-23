#!/bin/bash -e
set -x
# This script add a CI build artifact of a bench to the bench reference site
cd $(dirname $0)
# defaults
HERE=`readlink -e .`
# fail on any command error
set -e

function help {
  echo "Usage: $0 BUILD_PATH SITE_PATH"
  echo "  -c category : like milestone, continuous, misc or workbench (default to workbench)"
  echo "  -u          : only update data file stats"
  echo "  -n          : skip git commands"
  exit 0
}

function git_pull() {
  if [ -z $GIT_SKIP ]; then
    git checkout master
    git pull
  fi
}

function git_add_file() {
  if [ -z $GIT_SKIP ]; then
    file_path=$1
    shift
    git add $file_path
  fi
}

function git_commit() {
  if [ -z $GIT_SKIP ]; then
    git commit -m"Adding build $BUILD_NUMBER in category $CATEGORY"
    git push
  fi
}

function get_build_info() {
  # need dbprofile, benchsuite
  export BUILD_NUMBER=`grep build_number $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCH_SUITE=`grep bench_suite $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCH_DATE=`grep import_date $DATA_SRC_FILE | cut -d \: -f 2- | sed 's,",,g;s,^ *,,g;s,\ ,T,g'`
  export DBPROFILE=`grep dbprofile $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export NUXEONODES=`grep nuxeonodes $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export CLASSIFIER=`grep classifier $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export DEFAULT_CATEGORY=`grep default_category $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  if [ -z $CATEGORY ]; then
    if [ -z $DEFAULT_CATEGORY ]; then
      export CATEGORY=workbench
    else
      export CATEGORY=$DEFAULT_CATEGORY
    fi
  fi
  if [ "$BENCH_SUITE" == "auto" ]; then
    bdate=`echo $BENCH_DATE | cut -dT -f 1`
    week=`date -d $bdate +%yw%V`
    export BENCH_SUITE="$week CI Weekly Benchmark"
  fi
  export DATA_FILE=$HERE/data/bench/$BUILD_NUMBER.yml
  export CONTENT_FILE=$HERE/content/$CATEGORY/$BUILD_NUMBER.md
  export BUILD_DEST_PATH=$SITE_PATH/build/$BUILD_NUMBER
}

function copy_build() {
  if [[ $BUILD_DEST_PATH = s3* ]]; then
    copy_build_s3
  else
    copy_build_local
  fi
}

function copy_build_s3() {
   gzip $BUILD_SRC_PATH/log || true
   #time s3cmd sync $BUILD_SRC_PATH $SITE_PATH/build/
   time aws s3 sync $BUILD_SRC_PATH $BUILD_DEST_PATH/
   gunzip $BUILD_SRC_PATH/log.gz || true
}

function copy_build_local() {
  mkdir -p $BUILD_DEST_PATH
  rsync -ahz --delete $BUILD_SRC_PATH/ $BUILD_DEST_PATH
  gzip $BUILD_DEST_PATH/log || true
  [ -f $BUILD_DEST_PATH/log ] && rm $BUILD_DEST_PATH/log || true
}

function add_data() {
  mkdir -p `dirname $DATA_FILE`
  cp -a $DATA_SRC_FILE $DATA_FILE
  git_add_file $DATA_FILE
}

function update_data() {
  set +e
  # parse info to extract more stats if not alreaddy present
  # Extract the mass import document stats
  import_dps=`tail -n1 $BUILD_SRC_PATH/archive/logs/*/perf*.csv | cut -d \; -f3 | LC_ALL=C xargs printf "%.1f"`
  import_docs=`tail -n1 $BUILD_SRC_PATH/archive/logs/*/perf*.csv |  cut -d \; -f2 | LC_ALL=C xargs printf "%.0f"`
  # Extract reindex stats
  reindex_docs=`grep 'ScrollingIndexingWorker.*has submited ' $BUILD_SRC_PATH/archive/logs/*/server.log | sed -e 's,^.*submited.,,g;s,.documents.*$,,g' `
  reindex_ms=`grep reindex_waitforasync_avg $DATA_SRC_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  reindex_dps=`awk "BEGIN {printf \"%.1f\", $reindex_docs/($reindex_ms / 1000)}" || echo "NA"`
  set -e
  # update target data file
  grep -q '^import_dps:' $DATA_FILE && sed -i "s/^import_dps\:.*/import_dps\: $import_dps/" $DATA_FILE || echo "import_dps: $import_dps" >> $DATA_FILE
  grep -q '^import_docs:' $DATA_FILE && sed -i "s/^import_docs\:.*/import_docs\: $import_docs/" $DATA_FILE || echo "import_docs: $import_docs" >> $DATA_FILE
  grep -q '^reindex_docs:' $DATA_FILE && sed -i "s/^reindex_docs\:.*/reindex_docs\: $reindex_docs/" $DATA_FILE || echo "reindex_docs: $reindex_docs" >> $DATA_FILE
  grep -q '^reindex_dps:' $DATA_FILE && sed -i "s/^reindex_dps\:.*/reindex_dps\: $reindex_dps/" $DATA_FILE || echo "reindex_dps: $reindex_dps" >> $DATA_FILE
  git_add_file $DATA_FILE
}


function add_content() {
  mkdir -p `dirname $CONTENT_FILE`
  cat > $CONTENT_FILE << EOF
---
title: "$DBPROFILE $NUXEONODES $BUILD_NUMBER"
bench_suite: "$BENCH_SUITE"
build_number: "$BUILD_NUMBER"
dbprofile: "$DBPROFILE"
classifier: "$CLASSIFIER"
date: $BENCH_DATE
type: "bench"
---
EOF
  git_add_file $CONTENT_FILE
}

# -------------------------------------------------------
# main
#
while getopts "c:hun" opt; do
    case $opt in
        h)
            help
            ;;
        c)
            CATEGORY=$OPTARG
            ;;
        u)
            ONLY_UPDATE=true
            ;;
        n)
            GIT_SKIP="true"
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))
BUILD_SRC_PATH=$1
shift
SITE_PATH=$1
shift
DATA_SRC_FILE=$BUILD_SRC_PATH/archive/reports/data.yml
[ -r $DATA_SRC_FILE ]


get_build_info
git_pull
if [ -z "$ONLY_UPDATE" ]; then
  copy_build
  add_data
  update_data
  add_content
else
  update_data
fi
git_commit
echo "Done"
