#!/bin/bash -e
set -x
# This script add a CI build artifact of a bench to the bench reference site
cd $(dirname $0)
# defaults
HERE=`readlink -e .`
CATEGORY="continuous"
# fail on any command error
set -e


function help {
  echo "Usage: $0 BUILD_PATH SITE_PATH"
  echo "  -c category : like milestone, continuous, misc (default to continous)"
  echo "  -u          : only update data file stats"
  exit 0
}


function get_artifact_info() {
  # need dbprofile, benchid, benchname
  export BENCHID=`grep benchid $DATA_FILE | cut -d \: -f 2 | sed 's,[" ],,g'`
  export DBPROFILE=`grep dbprofile $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHNAME=`grep benchname $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BUILDID=`grep build_number $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHDATE=`grep import_date $DATA_FILE | cut -d \: -f 2- | sed 's,",,g;s,^ *,,g;s,\ ,T,g'`
  export NUXEONODES=`grep nuxeonodes $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  export BENCHFILE="$DBPROFILE$BUILDID"
}

function copy_artifact() {
  mkdir -p $SITE_PATH/static/build/$BENCHID
  rsync -ahz --delete $BUILD_PATH/ $SITE_PATH/static/build/$BENCHID/$BENCHFILE
  gzip $SITE_PATH/static/build/$BENCHID/$BENCHFILE/log || true
}

function add_data() {
  mkdir -p $SITE_PATH/data/bench
  cp -a $DATA_FILE $SITE_PATH/data/bench/$BENCHID$BENCHFILE.yml
}

function update_data() {
  set +e
  # parse info to extract more stats if not alreaddy present
  # Extract the mass import document stats
  import_dps=`tail -n1 $BUILD_PATH/archive/logs/*/perf*.csv | cut -d \; -f3 | LC_ALL=C xargs printf "%.1f"`
  import_docs=`tail -n1 $BUILD_PATH/archive/logs/*/perf*.csv |  cut -d \; -f2 | LC_ALL=C xargs printf "%.0f"`
  # Extract reindex stats
  reindex_docs=`grep 'ScrollingIndexingWorker.*has submited ' $BUILD_PATH/archive/logs/*/server.log | sed -e 's,^.*submited.,,g;s,.documents.*$,,g' `
  reindex_ms=`grep reindex_waitforasync_avg $DATA_FILE | cut -d \: -f 2 | sed 's,",,g;s,^ *,,g'`
  reindex_dps=`awk "BEGIN {printf \"%.1f\", $reindex_docs/($reindex_ms / 1000)}" || echo "NA"`
  set -e
  # update target data file
  data_file=$SITE_PATH/data/bench/$BENCHID$BENCHFILE.yml
  grep -q '^import_dps:' $data_file && sed -i "s/^import_dps\:.*/import_dps\: $import_dps/" $data_file || echo "import_dps: $import_dps" >> $data_file
  grep -q '^import_docs:' $data_file && sed -i "s/^import_docs\:.*/import_docs\: $import_docs/" $data_file || echo "import_docs: $import_docs" >> $data_file
  grep -q '^reindex_docs:' $data_file && sed -i "s/^reindex_docs\:.*/reindex_docs\: $reindex_docs/" $data_file || echo "reindex_docs: $reindex_docs" >> $data_file
  grep -q '^reindex_dps:' $data_file && sed -i "s/^reindex_dps\:.*/reindex_dps\: $reindex_dps/" $data_file || echo "reindex_dps: $reindex_dps" >> $data_file
}


function add_content() {
  mkdir -p $SITE_PATH/content/$CATEGORY/$BENCHID
  cat > $SITE_PATH/content/$CATEGORY/$BENCHID/$BENCHFILE.md << EOF
---
title: "$DBPROFILE $NUXEONODES $BUILDID"
dfile: "$BENCHID$BENCHFILE"
benchid: "$BENCHID"
benchname: "$BENCHNAME"
dbprofile: "$DBPROFILE"
date: $BENCHDATE
type: bench
---
EOF
}

# -------------------------------------------------------
# main
#
while getopts "c:hu" opt; do
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
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))
BUILD_PATH=$1
shift
SITE_PATH=$1
shift
DATA_FILE=$BUILD_PATH/archive/reports/data.yml
[ -r $DATA_FILE ]


get_artifact_info
if [ -z "$ONLY_UPDATE" ]; then
  copy_artifact
  add_data
  update_data
  add_content
else
  update_data
fi
echo "Done"
