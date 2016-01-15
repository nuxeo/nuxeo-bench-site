# Nuxeo Benchmark Reference Site

This is the reference benchmark site builder, to be used by a jenkins job.

There are 2 jobs that run on master:
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site-add/ to add a new bench to the site
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site/ to update the site

The git repo don't contain any data, the data must be persisted, for instance the following symlink must be set on
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace and
/jenkins/.jenkins/jobs/nuxeo-reference-site-add/workspace:

data_all -> /opt/build/bench-reference-site-data/data
public -> /opt/build/bench-reference-site-data/public
static -> /opt/build/bench-reference-site-data/static
