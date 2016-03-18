# Nuxeo Benchmark Reference Site

This is the reference benchmark site builder, to be used by a jenkins job.

There are 2 jobs that run:
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site-add/ to add a new bench to the site
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site/ to update the site

The first job trigger the second.

The site-add job must run on master to be able access the artifacts of the bench job (nuxeo-reference-bench). 

The git repo doesn't contain the reports (build artifacts).
These data are persisted in the /opt/build/bench-reference-site-data/build

The static site generated is in ./public and should be a link, on the nuxeo-reference-site workspace:
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace/public -> /opt/build/bench-reference-site-data/public

