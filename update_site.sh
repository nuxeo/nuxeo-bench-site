#!/bin/bash -e
# Update the site with the latest change
cd $(dirname $0)
# fail on any command error
set -e

SITE_PATH=$1
shift

hugo_path=$(which hugo) || true
if [ -x "$hugo_path" ] ; then
  HUGO=hugo
else
  HUGO=/opt/build/tools/hugo/hugo
fi

function rebuild_site() {
  pushd $SITE_PATH
  $HUGO --theme=hyde
  popd
}

# -------------------------------------------------------
# main
#
rebuild_site
