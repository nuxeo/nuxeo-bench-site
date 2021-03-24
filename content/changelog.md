---
title: "Changelog"
slug: "changes"
---

Here are some import changes on the Benchmark infrastructure and tests that
should be take in account to interpret performance evolution.

- 2021-03-22 Use Zulu JDK 11 instead of OpenJDK 11


- 2020-10-29 Upgrade to Elasticsearch 7.9.3


- 2019-10-08 Upgrade to Elasticsearch 6.8.3 OpenJDK 11


- 2018-10-18 Upgrade to Elasticsearch 6.4.2 OpenJDK 8 (previously 6.3.2)


- 2018-08-14 Wait properly on audit writes between simulation


- 2018-08-14 Make sure existing elasticsearch indexes are dropped on start


- 2018-08-13 Elasticsearch 6.3.2 all index in translog async


- 2018-06-22 Upgrade Ubuntu on elasticsearch and nuxeo nodes to 16.04


- 2018-06-22 Switch to Elasticsearch 6.3.0 (18w26)


- 2017-10-07 Use Elasticsearch Rest client instead of Transport client


- 2017-10-01 Update to Elasticsearch 5.6


- 2016-08-30 Upgarde Elasticsearch 2.x
  Nuxeo 8.4-SNAPSHOT/8.10 requires Elasticsearch 2.x, the cluster is upgrade from a 1.7.3 to 2.3.5


- 2016-05-09 New cluster for Jenkins slave
  New on demand c3.xlarge slave.


- 2016-04-27 Read simulation do not load external entities
  This was due to NXP-19581.


- 2016-04-27 Adding a new Search simulation
  The Navigation simulation is now referred as Read simulation


