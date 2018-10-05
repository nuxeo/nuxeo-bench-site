#!/bin/bash -e
# Update the site with the latest change
cd $(dirname $0)
# fail on any command error
set -e


function help {
  echo "Build the benchmark site with hugo, deploy on S3"
  echo "Usage: $0 [S3_BUCKET]"
  exit 0
}


hugo_path=$(which hugo) || true
if [ -x "$hugo_path" ] ; then
  HUGO=hugo
else
  HUGO=/opt/build/tools/hugo/hugo
fi

function rebuild_site() {
  $HUGO --theme=hyde
}

function sync_s3() {
  local S3_BUCKET=$1
  shift
  time aws s3 sync ./public/ $S3_BUCKET/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
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
S3_BUCKET=$1

rebuild_site
if [ ! -z $S3_BUCKET ]; then
  sync_s3 $S3_BUCKET
fi
