#!/bin/bash -e
# Update the site with the latest change
cd $(dirname $0)
# fail on any command error
set -e
set -x
SITE_PATH=$1
shift

hugo_path=$(which hugo) || true
if [ -x "$hugo_path" ] ; then
  HUGO=hugo
else
  HUGO=/opt/build/tools/hugo/hugo
fi

function rebuild_site() {
  # The data and content directories can not be symlink so
  # we need to copy the data first
  rsync -avz --delete $SITE_PATH/data/ ./data
  rsync -avz --delete $SITE_PATH/content/bench/ ./content/bench
  $HUGO --theme=hyde
  # the localt ./static and ./public are symlink to SITE_PATH/static & public
}

# -------------------------------------------------------
# main
#
rebuild_site
