# Nuxeo Benchmark Reference Site

This is the reference benchmark site builder, to be used by a jenkins job.

The script add a jenkins reference bench build to the site, 

The git repo don't contain any data, the data must be persisted, for instance the following symlink must be set on
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace:

data_all -> /opt/build/bench-reference-site-data/data
public -> /opt/build/bench-reference-site-data/public
static -> /opt/build/bench-reference-site-data/static
