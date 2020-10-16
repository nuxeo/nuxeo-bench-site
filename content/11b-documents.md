---
title: "An 11 Billion Docs Benchmark Story"
slug: "11-billion-benchmark-story"
layout: "post"
---

## I - Why a 10B documents benchmark in 2020

> This chapter presents the reasons why we wanted to run a new benchmark campaign in 2020

### Not our first benchmarks

In the past, we published several large scale benchmarks:

- we did at least two different benchmarks with 1B documents
  - [one with a single application using 10 repositories using 10 PGSQL servers](https://www.nuxeo.com/blog/one-billion-documents/)
  - [one with a single repository leveraging a sharded MongoDB cluster](https://benchmarks.nuxeo.com/custom/1/index.html)
- we did a DAM Benchmark
  - with a focus on handling large files (upload, download, conversions)
  - scaling workers nodes to allow high-throughput processing
- we have a continuous benchmark run directly by out Continuous Integration
  - https://benchmarks.nuxeo.com/

What we want to do differently this time:

- Go beyond the 1B documents mark and reach 10B+
- Make the benchmark as realistic as possible

We want the benchmark to be as realistic as possible to provide our customers and our ops team real answers on what a multi-billions repository architecture looks like and the different scalability steps between 1B and 10B.

To achieve this goal, there are some additional constraints:

- we need to use a real production infrastructure
  - we can not merely rely on a benchmark "test Lab" where we would have more tweaking capabilities
- test actual use cases with a meaningful dataset
  - we want to test a real application so we can get actionable insights

### Production-like, not a lab

**Nuxeo Cloud infrastructure**

The goal is to leverage our Nuxeo Cloud automation to deploy the Nuxeo Application precisely the way we do for our customers.
In our case, it means:

- deploy Nuxeo using Docker containers on EC2
- leverage PaaS Services
  - AWS Elasticsearch
  - AWS MSK for Kafka
  - AWS S3 for blob storage
  - MongoDB Atlas for the database
- deploy everything using the existing automation
  - Terraform for AWS automation
  - rely on Nuxeo Configuration template system
  - Leverage build pipeline of Nuxeo Cloud to bake the custom Docker images

#### Production infrastructure

Not only is the AWS infrastructure provisioned automatically using Terraform, but we also comply with all the security and production rules:

- Everything secured and encrypted
  - all communications are TLS encrypted
  - encryption at REST for all storage
- all security systems are on
  - including Antivirus and IDS
- rely on DataDog for monitoring
  - improve existing Dashboard and add metrics as needed

**Dashboard for Phase 1**

<img src="/images/11b/01-dashboard-phase1.png" alt="Dashboard for Phase 1" width="800px">

**Dashboard for Phase 2**

<img src="/images/11b/02-dashboard-phase2.png" alt="Dashboard for Phase 2" width="800px">

The goal is to define architecture blueprints of what infrastructure we need to deploy a 1B, 2B, 3B, or 10B documents Nuxeo application inside Nuxeo Cloud.

### Testing an application - not a storage service

To extract meaningful insights, we want to test an application that reliably translates the challenges our customers will be facing in the future.
We want to tests a content-centric application with real use cases, not just benchmarking a database.

Our starting point was to interview some customers to better understand their requirements and challenges regarding future scalability.
The main takeaway is that while the existing benchmarks well cover the standard DM and DAM use cases, some uses cases in the financial industry were not.

A typical use case would be building a large consolidated document repository collecting all the data on customers for a bank or an insurance company.

In addition to the ability to scale to multiple billions of documents, the requirements were:

- We want a flexible and cost-efficient solution
  - cost cannot be linear with volume
- We want a content application with all the expected features
  - with attached files associated with the metadata
  - with indexing, including Fulltext
  - with security
- We need the resulting application to be usable IRL
  - can run bulk import without killing the application (support for mixed workloads)
  - we need to be able to run a full reindex
  - we need to be able to apply a bulk operations on a large number of documents

---

## II - Phases and Methodology

> This chapter presents how we structured our benchmarking effort.

### Phases

We know from our past experiences that doing a benchmark can be very time-consuming, and we decided to split the effort into 2 phases with different goals and deliverables.

<img src="/images/11b/03-phases.png" alt="Phases" width="800px">

#### Phase 1

This first phase aims to provide guidance to our customers who will reach 1B, 2B, or more documents in the next 18 months.

Since most of these customers have already deployed their Nuxeo application, we need to apply some constraints:

- use an already released LTS version: Nuxeo 10.10 LTS
- we cannot alter the existing file plan: sharding is not an option

Deliverables for Phase 1:

- tests against a 3B documents repository
- key scalability steps
  - know what the bottlenecks are
  - understand what we need to monitor
  - know when we need to scale out/up
- reference architectures for 1B, 2B, 3B documents
  - hardware
  - expected performances

#### Phase 2

We know that we will host multi-billions repositories within the next 18 months.

We want to be ahead of these deployments: clear the way for these projects and have some data to be able to guide them.

For phase 2:

- we want to push the benchmark to 10B+ documents
- we want to leverage sharding capabilities to optimize infrastructure costs
  - sharding at the application level (multi-repository)
  - sharding at the storage level (i.e., MongoDB and Elasticsearch sharding)
- we want to leverage the "Cloud version" of Nuxeo
  - Nuxeo 11.x

Deliverables for Phase 2:

- tests against a 10B+ documents application
- sharding architecture
- Live Demo and Continuous testing

This last point means that we are not aiming for a "one-shot" benchmark.
We want to run this benchmark continuously to verify that performance evolves with the platform in the right way.

We also want to have the capability to rebuild this 10B+ documents demo on-demand so that people who need to "see it to believe it" can do it.

<img src="/images/11b/04-ci-pipeline.png" alt="CI Pipeline" width="400px">

#### Phase 1 & Step by Step approach

We want to identify the scalability steps, so it implies:

- volumize step by step
- test performance for each of the steps
- adjust hardware as needed

The volumization is part of the testing process, for each of the steps:

- generate xM documents
- import xM documents
- index xM documents

We gather metrics for each technical task.

<img src="/images/11b/05-import-pipeline.png" alt="Import Pipeline" width="800px">

Once each step is reached, we run complete functional tests using Gatling:

- CRUD API Tests
  - Create Documents (including file upload)
  - Update Documents
  - Read Documents
- Navigation Tests
  - Browse the repository by physical hierarchy
  - Browse the repository via search
- Enrichers tests
  - Check the impact of the various enrichers on the global throughput
- Search tests
  - Complex and full-text search
  - Aggregates

For each major step (1B, 2B, 3B) we run some additional tests like:

- Nuxeo std performance tests
- Mixed workload (i.e. Bulk Import + CRUD)
- Full Reindex
- Bulk Updates
- Etc.

<img src="/images/11b/06-steps-by-steps.png" alt="Step by step increasing volume" width="800px">

#### Phase 2 & Volumize and test

Phase 2, timewise, we could not afford to do the same step by step approach.

So, we relied on what we learned during Phase 1 to define:

- how to split the data in multiple repositories
- what kind of hardware to use for each repository
- how to index data for each repository

So, unlike Phase 1, the Phase 2 benchmark contains fewer steps:

- generate all the data
- import and index 11B documents
- test
- scale down & re-test

Because we wanted this benchmark to be a learning experience, we also used the long import process to test different import strategies:

- optimize data partitioning in Kafka to speed up the import
- leverage MongoDB Read Preferences to increase throughput when reindexing
- integrate indexing as part of the bulk import process
- ...

It may seem obvious, but 11 Billion documents is a lot, so we need to be careful with the import throughput.
This is the reason why we choose to leverage cloud elasticity and define 2 different architectures:

- one import architecture
  - using enough hardware to be sure we can import 11B documents in a reasonable time
- one standard operation architecture
  - reduce the hardware cost by scaling down to a "good enough" infrastructure

---

## III - Content generation and Fileplan strategies

> This chapter focuses on how we generated the 10B documents and how we stored them in Nuxeo repositories.

### Why realistic data does matter

To tests a 10B documents repository, we need to have 10B documents that are:

- different from each other
- otherwise, indexing is not realistic
- caches and low-level optimization will skew the results
- valid
- pdf, Docx, and images need to all be valid so that we can run conversion and text extraction

### Challenges with generating 10B files

Generating 10B unique documents and attachments (files) comes with a few challenges:

**Generation time**

Generation needs to have very high-throughput if we want the system to be usable.

For example, if we were to generate files at 1,000 files/s, it would still take more than 100 days to generate the 10B.

This means that we need to have a generator that generates both metadata and files at a much higher throughput.

During phase 2, the generation of the 11B documents in Kafka took about 4 days with an average throughput of 2 million doc/min.

<img src="/images/11b/07-import-metrics.png" alt="Import metrics" width="800px">

NB: the plateaus on a plot correspond to when it took me a few hours to trigger the next step of the initial data generation.

**Storage**

Storage costs on S3 depend on volume but also on the number of requests you issue.

In our case, doing 10B PUT on S3 would definitely not be cost-efficient, which is why we wanted to leverage the Snowball service.

However, at the time we wanted to initialize the data, we faced some issues:

- with the global pandemic context: we were unsure if / when the Snowball would arrive
  - (actually, it arrived on time and worked perfectly)
- generation was limited by the bandwidth to write on the Snowball
  - using the snowball archive format ended up being the best solution

Anyway, because of these uncertainties, we prepared a plan B that was to have the custom Nuxeo Blob Store that would generate the PDF files on the fly in a consistent and repeatable manner.
This was a way for us not to be too dependent on the Snowball availability (if things went wrong with shipping). (generating a PDF on the fly takes more resources than reading it from S3).

### Generation approach

#### Random yet reproducible

The core of the system is a java library that generates random metadata:

- personal information
  - first name and last name
  - DOB, address
  - customer identifier
- account information
  - account identifier
  - date
  - list of operations on the account

This data generation needs to be random (to avoid skewing the dataset), yet we need it to be reproducible so we can run the same generation process for several targets (Snowball, Importer, Gatling tests) and still have matching data.

#### Rendering

We use the randomly generated metadata to generate different types of files:

- Identity cards (as Jpeg image)
- Account opening Letters (as Docx document)
- monthly Statements (as PDF)

NB: the initial plan was to generate the identity cards are TIFF, but we did not find a way to write TIFF fast enough from Java and had to fall back to JPEG to avoid waiting for weeks.

#### Different clients

Multiple clients then use this data generation and rendition library:

- Command Line (CLI) tool used to fill the Snowball
  - generate Docx and Jpeg
  - generate CSV files
- `nuxeo-stream` Document producer generating Statements data on the fly
- Gatling tests using the CLI to generate tests data
- Custom BlobStore using the library to generate PDF files on the fly

<img src="/images/11b/08-gen-lib.png" alt="Data generation library" width="800px"/>

NB: The data generation library is available in this [github repository](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/tree/master/nuxeo-data-generator).

### File plan

The complete target content model includes:

- Customers
- Accounts
- Statements

<img src="/images/11b/09-hierarchy.png" alt="File hierarchy" width="500px">

#### Phase 1 File Plan

For Phase 1, we started the tests before the Snowball was shipped back: this means we did not have the data for Customers and Accounts.

So, we did the Phase 1 benchmark using only the Statement Document type and our ability to quickly generate as many statements as we wanted, both in terms of metadata and in terms of files.

<img src="/images/11b/10-hierarchy-phase-1.png" alt="File hierarchy phase 1" width="500px">

#### Phase 2 File Plan

For phase 2, we wanted to use the full content model:

- Customers
- Accounts: in average 2 Accounts per customer
- Statements: 5 years for each account (5\*12 statements)

Based on what was generated on the Snowball:

- 89,997,827 Customer documents
- 89,997,827 IDcard documents
- 179,998,862 Account documents
- 179,998,862 Correspondence
- 179,998,862\*60 Statement documents

Total = 89,997,827 x 2 + 179,998,862 x 62 = 11,339,925,098

The Data is split in 3 repositories:

- us-east
  - 50% of Customers/IDCards/Accounts...
  - 6 months of statements
- us-west
  - 50% of Customers/IDCards/Accounts...
  - 6 months of statements
- archives
  - 54 months of statements for all customers

This means:

- us-east : 0.8B
  - 89,997,827 + 179,998,862 + 179,998,862/2\*6
- us-west : 0.8B
  - 89,997,827 + 179,998,862 + 179,998,862/2\*6
- archives : 9,7B
  - 179,998,862\*54

<img src="/images/11b/11-hierarchy-phase-2.png" alt="File hierarchy phase 2" width="800px">

### Data Ingestion

#### Nuxeo Stream Importer

We used Nuxeo Stream importer to ingest the data.

The document import process runs in 2 steps:

- generate the documents into Kafka _(Document Producers)_
  - produce from CSV
  - directly use the data generation lib
- import the documents from Kafka into the Document Repository _(Document Consumers)_
  - create the actual Document in the repository hierarchy
  - associate the Document with Blobs

This two steps process provides a few advantages:

- decouple importing data from the outside from writing into the Nuxeo repository
  - it makes it much easier to identify the bottlenecks
  - we are sure to be able to import into the repository as fast as possible
- we can quickly stop/restart/reset the import
  - this is just about changing an offset in Kafka

For similar reasons, the import is initially done without indexing. Once the documents are imported, we use the Bulk Action Framework to trigger re-indexing.

Later during the Phase 2 benchmark, we used a new feature from 11.x to enable "on-the-fly" bulk indexing.

<img src="/images/11b/12-import-stream.png" alt="Improt Stream" width="800px">

#### Dedicated Importer node

A standard Nuxeo deployment usually contains 2 types of nodes:

- interactive / portal nodes
  - serve API and interactive workload
- worker nodes
  - handle the asynchronous processing

In the context of the benchmark, we added a 3rd type of Nuxeo node, "importer nodes":

- dedicated to running the import workload
  - do not serve interactive workload
  - do not run any asynchronous workload
- configured [specifically to speed up import](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/tree/master/package/src/main/resources/install/templates/importer-node)
  - remove some processing that is not needed for bulk import

Having one single Nuxeo importer node was enough to get the best possible throughput in nearly all the cases. However, we scaled up this node (compared to the other Nuxeo nodes) to ensure that data generation was not limited by CPU.

In the context of Phase 2, we did use 2 concurrent importer nodes against a big sharded MongoDB cluster to achieve a 25K docs/s import throughput.

---

## IV - Phase 1 test and results

> This chapter provides an overview of the results for Phase 1 and the takeaways from our tests.

### TL;DR:

- reached 3B documents
  - not a hard limit but seemed to be big enough for the phase 1 use case
- proven elasticity
  - we can maintain performance by adjusting infrastructure and application configuration
- it works in real life
  - we can use and operate a 3B documents repository
- using PaaS services truly make life easier
  - AWS ES / MSK & MongoDB Atlas

### Proven Elasticity

The main achievement is that from 0 to 3B documents, we were able to adjust the infrastructure to maintain the performance at the same level.

When you increase the number of documents, you expect that the performance will progressively decrease. The goal is to be sure that you can leverage the cloud elasticity to scale out or up, to maintain good performance for your workload.

<img src="/images/11b/13-phase1-resources-vs-perfs.png" alt="Phase 1: Resources vs. Performance" width="800px">

Based on the tests we did at each "volumization step", we were able to determine the limiting factor and scale-out/up the needed part:

- sometimes Nuxeo nodes
- sometimes Elasticsearch
- sometimes MongoDB

Obviously, the different aspects of the application (CRUD, Navigation, Search) do not evolve the same way with volume, so we optimized for what seemed to be the best trade-off for each step.

#### Nuxeo nodes

Nuxeo nodes can easily be added to the cluster dynamically when the workload needs it.

Typically:

- add Nuxeo interactive nodes when we need to serve more REST API calls
  - i.e., response time increase because of the database: add more Nuxeo nodes to handle the throughput
- add Nuxeo worker nodes when we need to process more asynchronous workload
  - bulk reindex
  - bulk update on a large number of documents

Nuxeo nodes are grouped in "AutoScalingGroups" according to their node type to make the scale-out process easy.

For example, during the Phase 1 benchmark, we did a full-reindex of the 3B documents repository and scaled the number of worker nodes to 9 in order to maximize throughput.

<img src="/images/11b/13a-phase1-3B-reindex.png" alt="Phase 1: 3B re-index" width="800px">

Unsurprisingly, you can start with the default settings, but the more the volume grows, the more you need to adjust the application settings to optimize for the workload you want to handle and to avoid adding more hardware unless absolutely necessary.

Here are some examples of the parameters we adjusted

- WebUI & Enrichers
  - disabled some enrichers that can ot scale with volume and are not needed in most cases
    - i.e. checking if each folder has children to display the "+"
- Adjust some PageProviders
  - switch from MongoDB to Elasticsearch
  - avoid asking for aggregate if not useful
- Leverage Node types to have a dedicated configuration

All configuration is available in this [git repository](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/tree/10.10-NXP-28966)

#### Data tier

Scaling data nodes can be a little bit trickier than the Nuxeo nodes because it can imply moving data and can make the whole process slower.

So, while you do not want to scale up and down as fast as you can do it on the Nuxeo side, we did really benefit from the full PaaS experience and were able to scale out or up in a manner that is easy and completely transparent for Nuxeo.

##### MongoDB

We used MongoDB Atlas on AWS as our primary database for all the tests.

MongoDB is the database that gives us more options in terms of scalability and sharding.

For Phase 1, we used a single non-sharded MongoDB Atlas Cluster.

Logically, the write throughput decreases with the volume.
The main limitation comes from the size of the indexes vs the available cluster memory.

If we were in a "test lab", we could easily have reduced the number of indexes we create by default in the MongoDB collection, and it would have allowed us to speed up the import.
However, in a real-life scenario, you still want to be able to use the document repository while you are importing content, so it is not possible to drop key indexes because it would create a lot of long-running queries that would cripple the database performance.

However, we did work on optimizing indexing by:

- using an alternate documentID
  - switch from 36 bytes GUID to 8 bytes long
- use sparse index whenever possible
  - see [this notebook for more details](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/master/notebooks/ToolBox/Repository-Cleanup.ipynb)

Repository configuration for Phase 1 is accessible here [optimized-repository-config.xml](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/10.10-NXP-28966/nuxeo-jitgen-blobstore/src/main/resources/OSGI-INF/optimized-repository-config.xml).

To speed up the importer as much as possible , we wanted to accelerate the IO on the MongoDB Atlas side.
Increasing IOPS gave some significant results, but we ended up using an NVMe cluster to maximize IOPS and to get the best of our MongoDB Cluster.

For this reason, we started the import using an M60 NMVe cluster.

As expected, the pure import throughput decreased with volume, and after 1B documents, we started to reach a point where the IO was slowing the cluster too much (CPU IO Wait to reach more than 10%).

We scaled directly to M200 because:

- M80 NVMe was probably not enough to reach 3B
- M200 is the first available NVMe config after M80

With the M200 cluster, the throughput almost recovered the same performance we had with an empty database, and the data migration was completely transparent.

<img src="/images/11b/14-phase1-import-perfs.png" alt="Phase 1: import performance" width="800px">

##### Elasticsearch

For Elasticseach, the first limiting factor was the CPU usage during the indexing.
After some profiling, we removed the `html_strip` from the analyzers and scaled out the cluster.

When doing the full-reindex, we can adjust the number of Nuxeo workers and the number of threads.
It allows us to choose how much pressure we want to put on the Elasticsearch cluster.

Elasticsearch has some built-in protection mechanisms (limited queues and circuit-breakers). Thanks to that, when Nuxeo nodes were sending too many indexing requests to the Elasticsearch clusters, the Nuxeo nodes received an error and stopped the processing.

NB: this is where you want to have thoughts about your [retry policies](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/10.10-NXP-28966/package/src/main/resources/install/templates/large-repository/nxserver/config/stream-bulk-config.xml.nxftl#L36)

Then around 1.5B documents, we started hitting the limit in terms of shard size: our total index was becoming too big for the initial number of shards, so we had to increase from 35 to 100.

We saw 2 types of queries that could overwhelm Elasticsearch and trigger the circuit breakers:

- queries matching too many documents
- usage of `fielddata`

**Queries matching too many documents**

The tests ran the same queries from 0 to 3B documents.

However, when the volume increased, some of the queries were started to match too many documents.
Basically, some queries that were initially retrieving a few hundreds of results were yielding x00,000 of results when reaching 2B documents repository.

As a side effect, it put much more pressure on Elasticsearch to:

- compute the aggregates
- do the sort

The first side effect of more pressure was to make the query become slower. Still, given the number of incoming queries, it increased the amount of Lucene index Elasticsearch needed to load into memory and ended up triggering the circuit breaker.

The key point is that the queries that were creating the issue were actually pointless: the tests were simulating a UI listing with aggregates and sorting, but doing this with x00,000+ results is actually not usable by a human anyway.
So, we simply added additional query criteria to make the query more selective, which solved the issue.

**`fielddata`**

The default Nuxeo Elasticsearch mapping was using [fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-fielddata.html) to index the title.
It allows for searching using the LIKE operator (i.e. dc:title like "something%").

As explained in the ES documentation and in [NXP-29357](https://jira.nuxeo.com/browse/NXP-29357) this does not scale and consumes too much memory.
Doing a full-text search will work, and we considered that not being able to do a "like" search on 2B records is an acceptable limit.

<img src="/images/11b/15-phase1-indexing-perfs.png" alt="Phase 1: Indexing performance" width="800px">
 
### Scalability steps

Hardware is only one aspect of the architecture.
As explained earlier, some settings were adjusted at the Nuxeo level and the MongoDB or Elasticsearch level.

#### 1B docs architecture

- Nuxeo Interactive nodes :
- 3x `m5.xlarge`
- Nuxeo Worker nodes:
- 2x `m5.xlarge`
- MongoDB:
- Atlas `M60 NVMe` non-sharded cluster (3 nodes)
- Elasticsearch
- 3x `r5.large.es` master nodes
- 9x `r5.2xlarge.es` data nodes
- Kafka
- 2x `m5.large.msk`

<img src="/images/11b/16-phase1-1B-arch.png" alt="Phase 1: 1B architecture" width="800px">

#### 2B docs architecture

- Nuxeo Interactive nodes :
- 4x `m5.xlarge`
- Nuxeo Worker nodes:
- 2x `m5.xlarge`
- MongoDB:
- Atlas `M200 NVMe` non-sharded cluster (3 nodes)
- Elasticsearch
- 3x `r5.large.es` master nodes
- 12x `m5.4xlarge.es` data nodes
- Kafka
- 2x `m5.large.msk`

Main changes:

- upgraded MongoDB cluster from M60 to M200
- moved ES nodes to m5 type
- increased number of ES shards from 35 to 100

<img src="/images/11b/17-phase1-2B-arch.png" alt="Phase 1: 2B architecture" width="800px">

#### 3B docs architecture

- Nuxeo Interactive nodes :
- 4x `m5.xlarge`
- Nuxeo Worker nodes:
- 2x `m5.xlarge`
- MongoDB:
- Atlas `M200 NVMe` non-sharded cluster (3 nodes)
- Elasticsearch
- 3x `r5.large.es` master nodes
- 16x `m5.4xlarge.es` data nodes
- Kafka
- 2x `m5.large.msk`

Main changes:

- added one Nuxeo node for interactive processing
- increased number of ES nodes

<img src="/images/11b/18-phase1-3B-arch.png" alt="Phase 1: 3B architecture" width="800px">

### Works in real-life

Our goal is not only to validate that we can import 3B documents inside a single repository, but also, we want to verify that such a repository can still be used in real-life operations:

- that users can have a good experience when using the application
- that heavy operations like reindexing and bulk operation can be efficiently executed

* repository remains usable for real-life application
* leverage Nuxeo architecture and Nuxeo stream to
* scale-out as needed the different parts of the infrastructure
* control the pressure/throttle as needed

#### Mixed workloads

In most uses cases described by our customers, the bulk import does not only happen at the very beginning.
For sure, being able to import the data super fast in order to do the initial migration is a crucial advantage. Still, but also we need to be able to import a large amount of data, potentially daily, without affecting the user experience.

Unlike during an initial import where we typically want to take as many resources as we can from the database, in a daily import, we want to be able to balance the resources so that users connected to the application do not have a degraded experience.

The idea is to have an architecture that allows controlling how much pressure we put on the database and throttling the injection if needed to preserve the user experience.

The 2 step import process already allows us to import into Kafka as fast as possible without impacting the user experience. Then we can configure how many threads we want to allocate to the `DocumentConsumers` and control how fast we want to import.

To verify that, we did several mixed workloads tests:

- CRUD API test + bulk import
- Navigation test + bulk import

For example, we did a bulk import + index of 15M documents on a 2B documents repository while running the CRUD tests:

- the 15M documents are imported and indexed in less than 45 minutes
  - Bulk import + index runs at about 5.5 K docs/s
- CRUD tests show an increase in response time of only 4%

<img src="/images/11b/19-phase1-import-vs-crud.png" alt="Phase 1: Import vs. CRUD" width="800px">

We also observed that depending on the limiting factor in the target platform, we can adjust the throttling:

- when doing the same import against a 1B docs repository on an M60, we need to throttle more to avoid using too much database resources
  - import runs then at 2.5 K docs/s
- when testing concurrently Navigation and Bulk Import+ Index against a 2B documents repository (M200) then Elasticsearch is the bottleneck, and it makes sense to reduce the indexing speed

#### Adjusting the infrastructure for temporary workload

When the repository reaches a significant volume, some operations can become daunting.
The fear is that they will last forever.
Such operations include:

- run a full Re-Index
  - for example, because of a change in the mapping
- do a bulk update on a large number of documents
  - i.e. small data migration

We cannot prevent such operations from becoming more expensive when the volume increases. However, we can scale-out the processing to make them execute faster.

**Redindex @3B**

To maximize the re-indexing speed, we did 2 things:

- increased the number of Nuxeo nodes to 9
- scaled out the Elasticsearch cluster to 16 nodes (m5.4xlarge)

We then ran the Reindex:

- Reindexed 3B documents in 24h
- Indexing throughput at 36K docs/s

<img src="/images/11b/20-phase1-3B-reindex.png" alt="Phase 1: 3B re-index" width="600px">

Once the Reindexing completed, we scaled down:

- Nuxeo worker nodes back to 2
- Elasticsearch cluster scaled down to 12 `r5.2xlarge`

We executed the scale down while running a Gatling test and saw:

- no impact for CRUD and Navigation workload
- increased search response time by 30%

Because we reduced the number of CPU by 60% and the memory by 25% and did everything while a workload was applied, it seems like a satisfactory proof that we can leverage cloud elasticity while keeping the platform running.

<img src="/images/11b/21-phase1-ES-downscale.png" alt="Phase 1: Elasticsearch downscale" width="600px">

** bulk update @3B**

We ran a bulk update operation and verified that we could adjust the effective throughput by adjusting Nuxeo worker nodes' number.

<img src="/images/11b/22-phase1-bulk-update.png" alt="Phase 1: bulk update" width="800px">

### Raw performance results

<img src="/images/11b/23-phase1-raw-perfs.png" alt="Phase 1: Raw Performance" width="800px">

### Resources

- Nuxeo Plugin used for the benchmark: [https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/ (branch 10.10-NXP-28966)](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/tree/10.10-NXP-28966/)
- Gatling tests: [https://github.com/nuxeo-sandbox/nuxeo-10b-fs-bench-simulation](https://github.com/nuxeo-sandbox/nuxeo-10b-fs-bench-simulation)
- Synthetic data: [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1khXypxW-Bjpqvk5hHL3txB3cqFyJ5UQ4r6Q5Q6GFZrI)
- Raw data and monitoring : [GDrive Folder](https://drive.google.com/drive/folders/1dEQfFSL8H3gdVpa8jqVYMFT5Y8GrKHVr)
- Jira top-level task: [NXP-28764](https://jira.nuxeo.com/browse/NXP-28764)

---

## V - Phase 2 principles: building a reproducible 11B documents repository benchmark

> This chapter explains how we designed Phase 2 of the benchmark and the underlying reasoning.

#### 11B is not just about doing x3.5 on the 3B benchmark

The first difference with Phase 1 is that we want to reach 10B+, but we do not want to keep increasing the 3B architecture until it gets to the target volume.

While we are confident that we could scale Nuxeo, MongoDB Atlas, and Elasticsearch to fit 10B+ documents inside a single non-sharded repository, it does not seem to be the best approach:

- cost wise it is likely not to be optimal
- from an operation standpoint, having a gigantic 11B repository is not ideal

This is why for this phase 2 of the benchmark, we want to partition the data between:

- 2 live repositories
  - that will have adequate resources to ensure it stays performant
  - that can easily be updated and where we can perform daily operations
- 1 archive repository
  - where the data is mainly read-only
  - where we can optimize storage for cost

The need to partition the data between "live/fresh" and "archive" was clearly expressed by most of our customers looking at a multi-billion document application.
In most cases, you do not have multiple billions of documents you need to work with regularly. However, you can have billions of documents that you rarely access but still need to be accessible and searchable in case you need them.

The partitioning of the data impact:

- what kind of MongoDB cluster we use
  - typically, we want to downscale the "Archive" MongoDB cluster to support mainly read-only
- what type of indexing we apply
  - we probably do not need to index all attributes and the full-text of the archived statements
- what kind of binary storage we use

  - we could use AWS S3 infrequent access for the blobs associated with the archive repository

#### Full Content Model

Another significant change is that the content model contains all content types defined inside the Studio project since we can rely on the data that was imported via the Snowball.

<img src="/images/11b/24-phase2-sharding.png" alt="Phase 2: Sharding" width="600px">

The initial split and MongoDB sizing were derived from phase 1 of the benchmark:

- M60 NVME can handle 1B+:
  - so it should be ok for 0.8B
- M60 NVME can handle 1B+ => M80 NVMe should be able to handle 2B+
  - 5xM80 should be able to handle about 10B

#### Experiment with various parameters

Because in phase 2 we use the 11.x version, it is easier to prototype and test new solutions.

In this context, we did a few experiments:

**Data partitioning in Kafka**

When doing bulk ingestion (Document Consumer) at more than 10,000 documents/s we know that even a small optimization can have a significant impact.
When creating a document, the Nuxeo Core needs to fetch the parent document to do the parent/child association.
Fetching the parent document is a very lightweight operation, but it still requires a round trip between the JVM and MongoDB: again, at 10,000+ operation per second, this round trip does count.

Nuxeo repository includes a Caching System to reduce this kind of round-trips when possible. However, when documents are randomly split between 48 Kafka partitions, there is no reason that documents that will end up being created by the same `CoreSession` will have the same parent and be able to benefit from cache.

After some experimentation, we saw that dispatching the document messages in a partition based on groups sharing the same parent does improve the cache hit ratio and almost double the import throughput.

See [SUPINT-1772](https://jira.nuxeo.com/browse/SUPINT-1772) for more details.

**MongoDB readpreferences**

MongoDB allows setting [ReadPreferences](https://docs.mongodb.com/manual/core/read-preference/) to leverage read from the secondary nodes.

In the context of bulk-indexing, it seemed like a good idea to try to leverage this capability to feed as fast as possible the Index Computation.

However, in the tests we did, this setting also created duplicates in the list of documents to re-index, probably because the read operations are not guaranteed to be repeatable.
While having a few duplicates should not be a blocker, it revealed a bug on our side (that was fixed) but forced us to temporarily drop this solution.

**Update the import process**

We made a few improvements to the importer system.

The first one is that we build a CSV importer that can be used via HTTP.
The principle is simple:

- we have a gigantic CSV file on the "client" side
- the java client split this CSV file in chunks and upload them to the server in multi-threads
- for each chunk, the server will allocate the thread-pool to produce DocumentMessages in Kafka using a CSV chunk as a source.

With that principle, with a single Nuxeo injector, we can upload and produce Documents in Kafka at 80K+ documents/s.
(see [DocumentProducers notebook for more details](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/master/notebooks/11B-Steps/Step%200%20-%20DocumentProducers.ipynb)

**Import + Bulk Indexing on the fly**

During Phase 1 and during the first steps of phase 1 we use the same approach:

- bulk import documents
- index the full repository

As explained earlier, this approach has some advantages, but in the context of the volumizing the 9B+ archives repository, it did not seem to be the best approach.

The goal was to chain the bulk import and bulk indexing without having to run a full scroller against the database.
Thanks to [NXP-29620](https://jira.nuxeo.com/browse/NXP-29620), we have a single pipeline that allows to chain import and indexing.

See below the monitoring corresponding to the last 2B documents that were imported inside the Archive repository, we can see:

- the number of documents rising from 0 to 2B+
- the MongoDB import throughput at around 13K docs/s
- the indexing in ES at approximately 780M docs/min

<img src="/images/11b/25-phase2-import-monitoring.png" alt="Phase 2: Import monitoring" width="600px">

#### Continuous improvement

We are very aware that running a full benchmark is a significant effort to put all the pieces together.

We want to be able to capitalize on this effort and progressively integrate the work done for this 11B benchmark our continuous integration and release pipeline, pretty much as we did with the [default performance test suite](https://github.com/nuxeo/nuxeo/tree/master/ftests/nuxeo-server-gatling-tests) and the site [benchmarks.nuxeo.com](https://benchmarks.nuxeo.com/).

Ideally, we want to be able to:

- run multi-billions tests regularly
- be able to quickly build a demo site with multiple billions of documents

The challenge is that running such a benchmark requires to coordinate a lot of different moving pieces:

- Data Generation
  - i.e. generate the binary files for Snowball or for S3
  - i.e. generate the CSV files
- Import the data into Kafka
  - i.e. run the Documents Producers
- Adjust the infrastructure to the current phase of the test
  - i.e. update the Auto-Scaling group to add or remove worker nodes
- Update configuration
  - i.e. change Elasticsearcg `refresh_rate` to -1 before bulk-indexing and to `null` after
- Run the tests
  - i.e. run Gatling tests
- Gather statistics
  - i.e. call MongoDB or Elasticsearch to gather statistics and used storage and indexes
- Documentation
  - i.e. explain the different steps and actions to be taken

To try to simplify this, we took the following steps:

- Package everything in a single Docker Container
  - Datagen CLI
  - Kafka/MongoDB clients
  - AWS Client
- Leverage Jupyter Notebook server
  - integrated into the Docker image
  - drive the different steps of the tests from NoteBooks

<img src="/images/11b/26-phase2-notebook.png" alt="Phase 2: NoteBook Tests" width="800px">

The usage of Notebook allows us to achieve a few goals:

- we can mix [documentation with execution commands](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/master/notebooks/Data-Generation-Examples.ipynb)
- we can allow interactive usage for debugging and adjustments
- we can also execute automatically (nbconvert and Notebook REST API)

<img src="/images/11b/27-phase2-notebook-flow.png" alt="Phase 2: Notebook Flow" width="800px">

#### Import architecture vs Run architecture

For the import architecture, we used M80 NVMe MongoDB cluster with 5 shards.
This big MongoDB cluster comes with significant cost, but it allowed us to import the documents inside the Archive repository as a great throughput. We reached 25,000 documents/s when importing the first few billions of documents and using 2 Nuxeo injector nodes to maximize the throughput.

Once the import is completed, we can down-scale the cluster to reduce the cost since we do not need the write throughput anymore for the archive repository.
We can also revert back from NVMe to simple EBS storage since we do not need the same amount of IO.

---

## VI - Phase 2 Results

> This chapter presents the results of the second phase of our benchmark

### Browsing an 11B documents repository

Here is a video showing the Nuxeo application running with 11B documents:

<a href="https://10b-benchmark-data.s3.amazonaws.com/B11-Nuxeo-demo.mp4" target="demo"><img src="/images/11b/27a-phase2-notebook-video.png" alt="Phase 2: NoteBook Video" width="400px"><a/>

### Volumization results

#### Bulk import

For Bulk-Import we were able to achieve **25K documents/s** leveraging:

- MongoDB sharding
  - dispatching write load across 5 replicasets
- 2 Nuxeo Importer nodes
  - each of them importing at 12.5K docs/s

Compared to the tests done in Phase 1, using sharding nearly doubled the import throughput.

The graphic below shows the row documents insert throughput at the MongoDB level.

<img src="/images/11b/28-phase2-25K-import.png" alt="Phase 2: 25K Import" width="800px">

The 2 graphics belows show 2 Nuxeo importer running both with 24 threads and importing documents inside the archives repository:

<img src="/images/11b/29-phase2-25K-import-monitoring.png" alt="Phase 2: 25K Import Monitoring" width="800px">

#### Bulk Reindex

We ran a full re-index of the archive repository at 3B documents.

The full Reindex was achieved in 14h, meaning that the average throughput was **57K documents/s**.

Here again, we do almost double the performance obtained in phase 1:

- we leverage more IO at the MongoDB cluster level
- we reduced the indexing required for the archives repository

The graphics below show:

- the Elasticsearch reindexing throughput (in documents / minute)
- the worker threads allocated to re-indexing on the Nuxeo side (8 worker nodes)

<img src="/images/11b/30-phase2-bulk-index.png" alt="Phase 2: Bulk index" width="800px">

#### Import + Index

With the new Import + Index pipeline leveraging the ExtralScroll from the Bulk Action Framework, we can import and index documents at a throughput of **15,000 documents/s**.

<img src="/images/11b/31-phase2-import-and-index.png" alt="Phase 2: Import and index" width="600px">

### Gatling tests results

We first run the Gatling tests with a variable number of threads to identify the optimum trade-off between throughput and response time.

<img src="/images/11b/32-phase2-gatling-trade-off.png" alt="Phase 2: Gatling Trade-off" width="800px">

Once we have identified how many threads we want to run, we re-run the tests for a longer duration to gather the results.

**CRUD API test**

- Throughput: **1,900+ request/s**
- P95 response time: < **220ms**

<img src="/images/11b/33-phase2-CRUD-gatling.png" alt="Phase 2: Gatling CRUD results" width="800px">

<img src="/images/11b/33a-phase2-CRUD-rates.png" alt="Phase 2: CRUD rates" width="800px">

[Full test report](https://10b-benchmark-data.s3.amazonaws.com/gatling-test-11B/sim10crud-20201001044118832/index.html)

**Navigation**

- Throughput: **830+ request/s**
- P95 response time: < **500ms**
- Mean response time: < **250ms**

<img src="/images/11b/34-phase2-Nav-gatling.png" alt="Phase 2: Gatling Navigation results" width="800px">

<img src="/images/11b/34a-phase2-Nav-rates.png" alt="Phase 2: Navigation rates" width="800px">

[Full test report](https://10b-benchmark-data.s3.amazonaws.com/gatling-test-11B/sim30navigation-20201001054838961/index.html)

**Search**

- Throughput: **400+ request/s**
- Mean response time: < **450ms**
- P95 response time: < **600ms**

<img src="/images/11b/35-phase2-Search-gatling.png" alt="Phase 2: Gatling Search results" width="800px">

<img src="/images/11b/35a-phase2-Search-rates.png" alt="Phase 2: Search rates" width="800px">

NB: as visible on the graph, there was a transient network issue during the test.

[Full test report](https://10b-benchmark-data.s3.amazonaws.com/gatling-test-11B/sim40search-20201001062201693/index.html)

### Results Summary

<img src="/images/11b/36-phase2-raw-perfs.png" alt="Phase 2: Raw Performance Statistics" width="800px">

### Down Sizing results

#### Motivations

The goal is to reduce the cost of the database used for the archives repository.
There are 3 steps in the downsizing:

- step 0: import configuration
  - 5xM80 NVMe : fast configuration to allow initial data import
- step 1: downsize but keep IO
  - 5xM40 EBS + 6000 IOPS : keep storage as fast as possible to speedup the migration
- step 2: final state
  - 5xM40 EBS with default IOPS

#### Cluster resizing

Going from Step 0 to Step 1 took about 4 days:

- Configuration change was started on September 30th at 10:30 AM
- Configuration change was completed on October 4th during the morning

Several aspects can explain the relatively slow migration:

- the cluster contains 5\*(3+1) nodes to update
- 3+1 is because NVMe configuration uses a hidden secondary node to facilitate backups
- the total volume of data to move is rather big
- 8.6 TB
- the migration is completely transparent for the application layer
- the cluster remains up and still accepts read & write operations

To verify the 3rd point, we ran a performance test during the cluster reconfiguration and did not notice any issue (this is actually [the report linked earlier](https://10b-benchmark-data.s3.amazonaws.com/gatling-test-11B/sim10crud-20201001044118832/index.html)).

After the migration was completed, we re-run the same tests to verify that the MongoDB cluster's downsizing for archives did not impact.

The tests gave very [similar results](https://10b-benchmark-data.s3.amazonaws.com/gatling-test-11B/1htest-afterM40-resize.zip), and we just see that the CPU of the MongoDB Sharded cluster used for Archive goes higher than before.

<img src="/images/11b/37-phase2-mongo-cpu.png" alt="Phase 2: MongoDB CPU graph" width="800px">

### Reference Architecture

#### Architecture used during data import

During the import:

- we use a 5xM80 Atlas cluster for the Archive repository to import the data fast enough
- we scale the number of Nuxeo worker nodes from 2 to 8 when needed
- we use up to 2 dedicated Nuxeo nodes for data ingestion

<img src="/images/11b/38-phase2-import-arch.png" alt="Phase 2: Import architecture" width="800px">

#### Run Architecture

Once the data has been imported, we can reconfigure the platform to be more cost-efficient and allocate resources where needed:

- no more injector node is needed
- we downscale the archives repository
  - 5xM80 NMVe to 5xM40 EBS
- we scale out the Nuxeo interactive nodes to allow a better throughput when using the REST API

<img src="/images/11b/39-phase2-run-arch.png" alt="Phase 2: Run architecture" width="800px">

#### Storage Statistics

<img src="/images/11b/40-phase2-storage-stats.png" alt="Phase 2: Storage Statistics">

### Phase 2 takeaways

#### These (repositories) go to eleven (Billion documents)

The initial goal was 10B, and because of the way we ran the data generation, we ended up with 11.3B documents in 3 repositories.

<a href="https://youtu.be/KOO5S4vxi0o"><img src="https://media.giphy.com/media/aqSl7Dw5HTojK/giphy.gif"/></a>

Here the critical result is not so much the total number of documents, but the fact that we can:

- split the data into multiples repositories
- adjust each repository storage according to cost/performances trade-off
- navigate through the 3 repositories in a transparent manner

By transparent, we mean:

- we search across multiple repositories
- we can have listing mixing documents coming from multiple repositories
- navigation is consistent and allows to switch to the correct repository transparently

#### Gain of Sharding with MongoDB

We leveraged the MongoDB Sharding to maximize write-throughput to speed-up the import of archives, and it allowed us to reach 25,000 documents/s.

#### Elasticsearch configuration

The Elasticsearch configuration we used for the 1B architecture was using 9 data nodes.
If we had applied the same configuration for 11B documents we would have needed more than 100 Elasticsearch data nodes.

Thanks to the multi-repositories approach, we were able to use multiples indexes and adjust the configuration according to each repository so that the target hardware configuration is less than double (16 data nodes), whereas we multiplied the data volume by 11.

#### PaaS and transparent infrastructure changes

Using AWS Elasticseach and MongoDB Atlas PaaS Services allowed us to resize the infrastructure dynamically, depending on our needs.
Because, with 11B documents you can not expect any storage change to be fast, it is essential to be able to make these changes while the application is live. The truth is that migration speed becomes much less important than maintaining the availability of the service.

With both AWS Elasticsearch and MongoDB Atlas, we were able to validate this capability. This is very important for our Nuxeo Cloud operation team.

### Resources

- Nuxeo Plugin used for the benchmark: [https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/ (master branch)](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/)
- Gatling tests: [https://github.com/nuxeo-sandbox/nuxeo-10b-fs-bench-simulation](https://github.com/nuxeo-sandbox/nuxeo-10b-fs-bench-simulation)
- [Spreadsheet](https://docs.google.com/spreadsheets/d/1A5NdnEmDC1xg59ovTM86js2hxJw1LR5sbMoTxZxVV84/edit#gid=1352204211) with Gatling Results
- Raw data and monitoring : [Notebook folder](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/tree/master/notebooks/11B-Steps/monitoring)
- Notes on 11B import: [Notebook Readme](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/master/notebooks/11B-Steps/ReadMe.ipynb)
- Step by Step recipe to generate and import data: [Notebook](https://github.com/nuxeo-sandbox/nuxeo-jit-blobstore/blob/master/notebooks/Generate-and-Import-Test-DataSet.ipynb)
- Jira top-level task: [NXP-28764](https://jira.nuxeo.com/browse/NXP-28764)
