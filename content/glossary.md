---
title: "Glossary"
---

## Simulations

The benchmark is a composed of a dozen of gatling simulations.

They are part of the [Nuxeo source](https://github.com/nuxeo/nuxeo/tree/master/nuxeo-distribution/nuxeo-distribution-cap-gatling-tests/).

### Mass import

This simulation use the 'nuxeo-platform-importer' to generate random document with attachement.

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
