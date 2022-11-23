---
title: "Infrastructure"
slug: "infra"
layout: "post"
---

# Benchmarks after 2021

Nuxeo benchmark infrastructure runs on Google Kubernetes Engine (GKE).

The benchmark infrastructure is composed of:
- a Nuxeo cluster composed of API & Worker nodes (number configurable, default 1 of each)
- a MongoDB backend
- a Elasticsearch node (or OpenSearch for LTS 2023)
- a Kafka cluster
- a shared binary storage (S3 bucket)
- a Jenkins pod to run the bench

Everything is deployed with the help of Helmfile and Helm Charts, the definition and settings are accessible [here](https://github.com/nuxeo/nuxeo/blob/2021/ci/helm/helmfile.yaml) for the _benchmark_ environment.

MongoDB and Elasticsearch are running on a dedicated Kubernetes node.

There's one Kafka node for one Nuxeo node, both running on the same dedicated Kubernetes node.

Each Kubernetes node is composed of GKE _e2-standard-16_ with 16 vCPU and 64 GB Memory.

The benchmark is driven by continuous integration jobs (Jenkins).

Here is a list of tools used to perform the benchmark:

- [Helmfile](https://helmfile.readthedocs.io/): to deploy services.
- [Gatling](http://gatling.io/): to generate load.
- [gatling-report](https://github.com/nuxeo/gatling-report): home made open source tool to expose Gatling results.
- [Datadog](https://www.datadoghq.com/): to monitor the whole stack (private access).
- [Hugo](http://gohugo.io/): to generate this static site.
- [Jenkins](https://jenkins.io/): to drive bench and manage results.

# Benchmarks before 2021

Nuxeo benchmark infrastructure runs on Amazon Web Service (AWS).
![Benchmarked Architecture](/images/architecture.png "Architecture deployed for the benchmark")

The benchmark infrastructure is composed of:

- a Nuxeo cluster
- a backend (database/MongoDB)
- an Elasticsearch cluster
- a shared binary storage (S3 bucket on AWS)
- a Redis server (Elasticache on AWS)
- a load balancer (ELB on AWS)
- a machine to run the bench (Jenkins slave)
- a monitoring server (Graphite)

This is a mix of static and dynamic parts:

- the Nuxeo and ES nodes are started/created on demand
- the database/MongoDB and Graphite nodes are started on demand (but not created)
- the ELB, ElastiCache and S3 bucket are static

**All these nodes are setup according to our recommendation.**

The benchmark is driven by continuous integration jobs (Jenkins).

Here is a list of tools used to perform the benchmark:

- [Ansible](https://www.ansible.com/): to start and setup nodes.
- [Gatling](http://gatling.io/): to generate load.
- [gatling-report](https://github.com/nuxeo/gatling-report): home made open source tool to expose Gatling results.
- [Graphite](http://graphite.wikidot.com/): to monitor.
- [Hugo](http://gohugo.io/): to generate this static site.
- [Jenkins](https://jenkins.io/): to drive bench and manage results.

## Amazon ec2 instance type

All machines are on Amazon and runs on the same availability zone (AZ).

| Node          | ec2 instance type |
| ------------- | ----------------- |
| Database      | `c4.2xlarge`      |
| Nuxeo         | `c4.xlarge`       |
| Elasticsearch | `c4.xlarge`       |
| Redis         | `cache.m3.large`  |
| Kafka         | `c4.xlarge`       |
| Jenkins slave | `c3.xlarge`       |

- `c4.2xlarge`:

  - 8 vCPU (31 ECU)
  - 15 GB Memory
  - Storage EBS
    - Optimized: max bandwidth: 125MB/s
    - General Purpose SSD (gp2) 20g 60/3000 IOPS + 100g 300/3000 IOPS
  - Network Performance: High

- `c4.xlarge`:

  - 4 vCPU (16 ECU)
  - 7.5 GB Memory
  - Storage EBS
    - Not optimized, bandwidth is shared with network
    - General Purpose SSD (gp2) 8g 24/3000 IOPS (+ 250g 750/3000 IOPS for Elasticsearch node)
  - Network Performance: High

- `cache.m3.large`

  - 2 vCPU
  - 6.05 GB Memory
  - Network Performance: Moderate
  - Redis Engine Version Compatibility: 2.8.23

- `c3.xlarge`:
  - 4 vCPU (14 ECU)
  - 7.5 GB Memory
  - Storage EBS
    - Not optimized, bandwidth is shared with network
    - General Purpose SSD (gp2) 50g 150/3000 IOPS
  - Network Performance: Moderate

Running a benchmark with the default setting requires 8 machines:

- 3 nodes for the Elasticsearch cluster
- 2 nodes for Nuxeo cluster
- 1 node for an SQL database or MongoDB
- 1 node for the monitoring
- 1 node to run the benchmark, this is done by a Jenkins slave

And when using Kafka there is an additional machine.

## Configuration

Operating system used:

- static nodes (Database, Monitoring): Ubuntu LTS 14.04 using ext4 filesystem.
- dynamic nodes (Nuxeo and Elasticsearch): Ubuntu LTS 16.04 using ext4 filesystem (since 2018-06)

### Nuxeo

The number of nodes in the Nuxeo Cluster can be configured (default is 2)

The Nuxeo is installed using a zip archive, there are additional packages installed:

- `amazon-s3-online-storage`: used to store binaries into S3
- `nuxeo-platform-importer`: used during the bench to generate random files.

[1]: https://github.com/nuxeo/nuxeo/tree/master/nuxeo-distribution/nuxeo-distribution-resources/src/main/resources/templates-tomcat/perf

In addition to the backend template, the [`perf`][1] template is used.
This template is provided in the default distribution and rely on Elasticsearch for fulltext search and most of the
page provider.

Nuxeo run with the latest Oracle JVM 1.8, the heap size is set to 80% of total memory (5.84g for a C4.xlarge with 7.5g),
the flight recoder option is active:

<div class="table-overflow">
<code>JAVA_OPTS</code>=<code>-server -Xms5984m -Xmx5984m -Dfile.encoding=UTF-8 -Dmail.mime.decodeparameters=true -Djava.util.Arrays.useLegacyMergeSort=true -Xloggc:"/opt/nuxeo/logs/gc.log" -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dcom.sun.management.jmxremote.autodiscovery=true -Dcom.sun.management.jdp.name=Nuxeo -XX:+UnlockCommercialFeatures -XX:+FlightRecorder -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true</code>
</div>

### Elasticsearch

Create a cluster of 3 nodes using the proper [Elasticsearch version](https://doc.nuxeo.com/nxdoc/compatibility-matrix/#elasticsearch).

The heap size is set to 50% of the available memory (3.75g)

Nuxeo uses the `perf` template that set
`elasticsearch.index.translog.durability=async` for all indexes (since
2018-08-13).

### Binary Storage: Amazon S3

Default S3 bucket.

### Load balancer: Amazon ELB

HTTP Listener

     Stickiness: LBCookieStickinessPolicy, expirationPeriod='86400'

Health check

- Ping target: `HTTP:8080/nuxeo/runningstatus`
- Timeout: `5 seconds`
- Interval: `20 seconds`
- Thresold: `2`

### Redis: Amazon Elasticache

Elasticache cluster with a single node using Redis 2.8.

### Kafka

Since 2018-08-22 we can run reference benchmark with Kafka.

Nuxeo is then configured to leverage Kafka instead of Redis:

- The Audit writer is using Kafka
- The WorkManager is using Kafka
- The PubSub service is using Kafka, which means that repository and directory invalidation rely on Kafka.

Also for MongoDB we switch the KeyValueStore from Redis to MongoDB, this way Redis can be completely disable.

The Kafka cluster is a single node (definitely not a production setup):

- Zookeeper 3.4.8-1 (Ubuntu 16.04 install)
- Kafka 2.12-1.1.1

### Databases

Database are setup using the recommended setup and tuning from our documentation.

#### PostgreSQL 9.4

[Default setup](https://doc.nuxeo.com/x/fwQz) for a 16g server:

- shared_buffers: 4GB
- effective_cache_size: 8GB
- work_mem: 16MB
- maintenance_work_mem: 1GB
- max_connections: 153

#### Oracle 12

[Default setup](https://doc.nuxeo.com/x/ywE7).

#### SQL Server 2012 (mssql)

[Default setup](https://doc.nuxeo.com/x/EgI7).

#### MongoDB 8.2

[Default setup](https://doc.nuxeo.com/x/yAEuAQ).

## Change log

The configuration must be updated to follow new dependencies visit the [Change log](../changes) page for more information.
