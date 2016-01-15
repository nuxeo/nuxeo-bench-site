# Nuxeo Benchmark Reference Site

This is the reference benchmark site builder, to be used by a jenkins job.

There are 2 jobs that run on master:
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site-add/ to add a new bench to the site
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site/ to update the site

The first job trigger the second.

The git repo don't contain any data. 
The data and the generated site are located:
/opt/build/bench-reference-site-data
 
To work the nuxeo-reference-site must have 2 symlink mapped to the data dir:
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace/static -> /opt/build/bench-reference-site-data/static
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace/public -> /opt/build/bench-reference-site-data/public

