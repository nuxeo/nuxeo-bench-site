---
title: "Scenarios"
---

## Sources

The benchmark is composed of a serie of a dozen of Gatling simulations.
Those simulations cover important use cases of a content platform such as mass import, create, read, search, browsing, update and delete of content.

They are part of the [Nuxeo source](https://github.com/nuxeo/nuxeo/tree/master/ftests/nuxeo-server-gatling-tests).

The simulations are driven by a [Jenkins job](https://github.com/nuxeo/nuxeo-bench/).

## Description

Each simulation plays a scenario with a concurrency that is part of the report, there is no pause (i.e. think time) between requests,
(except for the simulation Benchmarks mixing actions).

### Mass import

This simulation use the [nuxeo-platform-importer](https://github.com/nuxeo/nuxeo-platform-importer/) to generate random document with an attachement.
The attached binary file is stored in S3 and the fulltext is extracted and indexed. The import is run on a single Nuxeo node.

### Create document using REST

Create documents using the REST API. The documents are imported from a CSV file, there is no file attachement.

### Read using REST

Get a random folders and documents using the REST API with various metadata.

### Search using REST

Performs fulltext search using terms from a CSV file.

### Navigation JSF

Using the web UI, view a random folder and a document in it, view all document tabs.

### CRU+Delete using REST

CRUD is Create/Read/Update/Delete of document, this is done on top of previously imported documents.

### Benchmarks mixing actions

Mixing different simulations: Navigation JSF, Read and Update using REST. This simulation uses pauses between requests.

### Reindexing repository

Time to drop and recreate the Elasticsearch index, documents are loaded from the repository.

## Metrics

- Throughput sync: throughput as seen by a client submitting requests.
- Duration sync: total duration as seen by a client to process all the requests.
- Residual duration async: Residual duration for asynchronous operations such as fulltext extraction or indexing.
- Total duration: sync + redisual async durations.
- p50: Median or 50th percentile, response time where half of requests are delivered.
- p95: 95th percentile, response time where 95 percent ofrequests are delivered.
- min: Minimum response time for a page or request.
- 25.5ms(+/-10): Average response time for a request in millisecond, with standard deviation.
- Concurrency: number of concurrent requests.
