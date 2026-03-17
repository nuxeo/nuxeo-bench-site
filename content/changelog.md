---
title: "Changes"
slug: "changes"
layout: "post"
---

Here are some important changes on the benchmark infrastructure and simulations that
should be taken into account to interpret performance evolution.

## Simulation Changes

### 2026-03-31 Bench various enrichers (NXP-33520)

#### Sim30Navigation

The navigation simulation now benchmarks a much wider range of enrichers.
Previously, the simulation tested 7 request types; it now tests 20, covering most available document enrichers.

**Distribution changes:**

| Request | Before | After |
|---|---|---|
| Get document | 30% | 13% |
| Get document folder | 10% | 10% |
| Get document dc only | 10% | 10% |
| Get document with acl | 10% | 3% |
| Get document with breadcrumb | 10% | 3% |
| Get document with thumbnail | 10% | 3% |
| Get document with properties | 10% | 10% |
| Get document with versionLabel | 5% | 3% |
| Get document with lock | 5% | 3% |
| Get document with audit | — | 3% |
| Get document with collections and favorites | — | 3% |
| Get document with firstAccessibleAncestor | — | 3% |
| Get document folder with hasContent | — | 3% |
| Get document folder with hasFolderishChild | — | 3% |
| Get document with pendingTasks, runnableWorkflows, runningWorkflows | — | 3% |
| Get document with permissions | — | 3% |
| Get document with preview | — | 3% |
| Get document with publications | — | 3% |
| Get document with renditions | — | 3% |
| Get document with subscribedNotifications | — | 3% |
| Get document with subtypes | — | 3% |
| Get document with tags | — | 3% |
| Get document folder with userPreferences | — | 3% |

**Expected metric impact:** The overall Sim30Navigation response times will change because the request
mix is now more diverse. Enrichers like `audit`, `pendingTasks`, `runnableWorkflows`, or `permissions`
add server-side overhead compared to a plain document fetch.
Direct before/after comparison of this simulation's aggregate metrics with prior benchmarks is therefore not meaningful.

#### Sim20CreateDocuments

A call to `addPreferencesOnParent()` is now executed after each document creation.
This sets user preferences on the parent folder via `PUT /api/v1/{parentPath}/@preferences`.

**Expected metric impact:**
- Creation time roughly doubles (~1min 30s → ~3min).
- Creation rate drops from 1300–1550 docs/s to 900–1150 docs/s.

This additional overhead is expected and reflects a more realistic workload where user preferences are set during content creation.

---

## Infrastructure Changes

- 2022-11-21 Use MongoDB 6.0.2 and Kafka 3.3.1 for LTS 2023


- 2022-11-18 Use OpenSearch 1.3.6 instead of Elasticserach 7.9.2 for LTS 2023


- 2022-10-24 Benchmark Nuxeo LTS 2023 with Zulu JDK 17


- 2022-10-03 Change benchmark infrastructure from AWS EC2 to GKE


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


