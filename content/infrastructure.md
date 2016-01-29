---
title: "Benchmark infrastructure"
date: "2016-01-18"
slug: "infra"
---

## Overview

This page describes the Nuxeo benchmark infrastructure that run on Amazon Web Service (AWS).

## Infrastructure

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

All of this nodes are setup according to our recommandation.

The bench is driven by continuous integration jobs (Jenkins).

Here is a list of tools used to perform the benchmark:

- Ansible: to start and setup nodes.
- Gatling: to generate load.
- Home made open source tool to expose Gatling results.
- Graphite: to monitor.
- Hugo: to generate this static site.
- Jenkins: to drive bench and manage results.  

## Amazon ec2 instance type

All machines are on Amazon and runs on the same availability zone (AZ).

Databases uses a `c4.2xlarge`, Elasticache uses a `cache.m3.large`, all other nodes use `c4.xlarge`.

- c4.xlarge is:

    - 4 vCPU
    - 7.5 GiB Memory
    - 750 Mbps EBS throughput

- c4.2xlarge is:
    - 8 vCPU
    - 15 Gib Memory
    - 1000 Mbps EBS thoughput

- cache.m3.large
    - 2 vCPU
    - 6.05 Gib Memory


Running a benchmark with the default setting requires requires 8 machines:

- 3 nodes for Elasticsearch
- 2 nodes for Nuxeo
- 1 node for the database/MongoDB
- 1 node for the monitoring
- 1 node to run the benchmark (Jenkins slave)

## Configuration

### Nuxeo nodes

The number of nodex in the Nuxeo Cluster can be configured (default is 2) 

The Nuxeo is installed using a zip archive, there are additional packages installed:

 - `amazon-s3-online-storage`: used to store binaries into S3
 - `nuxeo-platform-importer`: used during the bench to generate random files.

[1]: https://github.com/nuxeo/nuxeo/tree/master/nuxeo-distribution/nuxeo-distribution-resources/src/main/resources/templates-tomcat/perf
In addition to the backend template, the [`perf`][1] template is used.
This template is provided in the default distribution and rely on Elasticsearch for fulltext search and most of the 
page provider.

Nuxeo run with the latest Oracle JVM 1.8, the heap size is set to 80% of total memory (5.84g for a C4.xlarge with 7.5g), 
the flight recoder option is active: 

> JAVA_OPTS=-server -Xms5984m -Xmx5984m -Dfile.encoding=UTF-8 -Dmail.mime.decodeparameters=true -Djava.util.Arrays.useLegacyMergeSort=true -Xloggc:"/opt/nuxeo/logs/gc.log" -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dcom.sun.management.jmxremote.autodiscovery=true -Dcom.sun.management.jdp.name=Nuxeo -XX:+UnlockCommercialFeatures -XX:+FlightRecorder -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true

### Elasticsearch

Create a cluster of 3 nodes using the latest 1.7 version.

The heap size is set to 50% of the available memory (3.75g)

### S3
Default S3 bucket.

### ELB
  HTTP Listener
  Stickiness: LBCookieStickinessPolicy, expirationPeriod='86400'
  Health check 
  
  - Ping target: HTTP:8080/nuxeo/runningstatus
  - Timeout: 5 seconds
  - Interval: 20 seconds
  - Thresold: 2
    
  
### Elasticache

  Cluster with a single node using Redis.
  Configured to disable eviction on memory pressure: `maxmemory-policy=noevictions`
  
### Databases

Database are setup using the recommanded setup and tuning from our documentation

#### PostgreSQL

#### Oracle 12

#### SQL Server 2012 (mssql)

#### MongoDB


# About Nuxeo

Nuxeo provides a modular, extensible Java-based
[open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep)
and packaged applications for
[document management](http://www.nuxeo.com/en/products/document-management),
[digital asset management](http://www.nuxeo.com/en/products/dam) and
[case management](http://www.nuxeo.com/en/products/case-management). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and extensive packaging
capabilities for building content applications.

More information on: <http://www.nuxeo.com/>

