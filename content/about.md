---
title: "About Nuxeo Benchmark"
date: "2016-01-18"
slug: "about"
---

## Overview

This page describes the Nuxeo benchmark simulations that are performed to get the results exposed in this site.

## Simulations

The benchmark is a composed of a dozen of gatling simulations.

They are part of the [Nuxeo source](https://github.com/nuxeo/nuxeo/tree/master/nuxeo-distribution/nuxeo-distribution-cap-gatling-tests/).

Here is a description of each simulations:

### Mass import

This simulation use the `nuxeo-platform-importer` to generate random document with attachement.

### Create document using REST

Create documents using the rest API. The documents are imported from a CSV file.

### Navigation REST

Get a random folder and document using the REST API.

### Navigation JSF

View a random folder and a document in it, view all document tabs.

### CRUD REST

Create a document, Read, Update and Delete it.

### Read/Write REST

Mixing JSF and Rest Navigation with Document update.

### Elasticsearch Reindexing

Time to drop and recreate the repository index.

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
