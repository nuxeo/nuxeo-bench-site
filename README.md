# Nuxeo Benchmark Reference Site

This is the reference benchmark site builder, to be used by a jenkins job.

There are 2 jobs that run on master:
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site-add/ to add a new bench to the site
- http://qa.nuxeo.org/jenkins/job/nuxeo-reference-site/ to update the site

The first job trigger the second.

They must run on master to be able access the artifacts of the benc job (nuxeo-reference-bench). 

The git repo doesn't contain :
- bench results (./content/bench)
- bench data (./data)
- bench details reports aka static resources (./static)

These data are persisted in the SITE_PATH (/opt/build/bench-reference-site-data)

Unfortunatly ./content and ./data can not be symlink so the data are first synchronized before generating
 "./public" static site,

This requires to create 2 symlink on the nuxeo-reference-site workspace:
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace/static -> /opt/build/bench-reference-site-data/static
/jenkins/.jenkins/jobs/nuxeo-reference-site/workspace/public -> /opt/build/bench-reference-site-data/public

