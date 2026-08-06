# AGENTS.md

Guide for agents working with benchmark data in this repository (a Hugo static site: https://benchmarks.nuxeo.com/).

## Finding data for a benchmark ID

A benchmark is identified by a `build_number` such as `platform-1402` or a plain number like `1206`.

For a given id `<ID>`:

- **Data file (raw metrics)**: `data/bench/<ID>.yml`
  - Flat YAML of `key: value` pairs, no nesting. This is the single source of truth for all metrics of that run.
- **Content file (page metadata)**: `content/<category>/<ID>.md`
  - `<category>` is one of `workbench`, `milestone`, `continuous`, `custom`, `misc` (see `data/bench/<ID>.yml` field `default_category`).
  - Front matter only (title, bench_suite, build_number, dbprofile, classifier, date, type). No body content is required; it links back to the data file via `build_number`.
  - Custom benchmarks (ad-hoc, not part of the reference suite) use `data/custombench/<ID>.yml` and `content/custom/<ID>.md` instead.

Example for `platform-1402`:
```
data/bench/platform-1402.yml       # metrics
content/workbench/platform-1402.md # page front matter
```

To find which category a benchmark lives in, grep for the id across `content/`:
```bash
grep -rl "<ID>" content/
```

Detailed reports (Gatling HTML reports, monitoring dashboards) are **not** stored in git; they live in S3/Jenkins and are only linked to from the rendered page (see `build_url`, and links like `/build/<ID>/archive/reports/...` in the templates).

## How the data.yml is produced

`add_build_to_site.sh` is run by CI after a benchmark completes. It:
1. Copies the CI job's `archive/reports/data.yml` into `data/bench/<ID>.yml`.
2. Copies the raw Gatling/report archives to the site's S3 build path (not to git).
3. Runs `update_data()` to compute/patch a few derived fields directly into the yml:
   - `import_dps` = `import_docs / import_duration` (docs per second for mass import), parsed from the importer's `perf*.csv` if present, otherwise computed from `import_docs` and `import_duration`.
   - `reindex_docs` = number of documents submitted to reindexing, parsed from `server.log` ("has submited N documents") if present, otherwise taken as-is from the yml.
   - `reindex_dps` = `reindex_docs / (reindex_reindex_avg_ms / 1000)` (uses the actual "Reindex" step average duration, not the whole `reindex_duration`).
4. Writes `content/<category>/<ID>.md` front matter from fields in the yml (`build_number`, `bench_suite`, `dbprofile`, `nuxeonodes`, `classifier`, `import_date` → `date`).

## Naming convention in data.yml

Each simulation contributes a group of keys prefixed by its short name, e.g. `import_`, `move_`, `bulk_`, `mbulk_`, `create_`, `nav_` (Read), `navjsf_`, `search_`, `update_`, `crud_`, `exportcsv_`, `bench_` (mixed actions), `reindex_`, `cleanup_`, `fullgc_`.

Common suffixes per simulation prefix:
- `_duration` — total wall-clock duration of the simulation, in **seconds**.
- `_avg`, `_std`, `_min`, `_p50`, `_p95`, `_max` — response time stats in **milliseconds** across all requests of the simulation.
- `_rps` — requests/sec throughput (sync, as seen by the Gatling client).
- `_count` — number of requests.
- `_percentError` / `_error` — error percentage / error count.
- `_user` — concurrency (number of Gatling users/threads).
- `_date`, `_start`, `_end` — simulation start date and start/end epoch millis (used to build Datadog dashboard links).
- `_<request_name>_name` and `_<request_name>_avg/std/min/p50/p95/max/rps/end` — per-individual-request breakdown within the simulation (request name is slugified: lowercased, spaces/punctuation removed), e.g. `nav_getdocument_avg`.

Async/residual metrics: some simulations run an async command then poll for completion, producing sibling groups like `createasync_`, `updateasync_`, `crudasync_` with just `_avg` (residual async duration ms), `_duration` (seconds) and `_count: 1` — this is added to the sync duration to get "Total duration" (see scenarios.md Metrics section).

Top-level (non-prefixed) fields:
- `benchmark_date`, `benchmark_duration` — overall run date and total duration in seconds (shown as "Duration" in the Overview table).
- `build_number`, `service`, `docker_image`, `build_url`, `job_name` — CI identification.
- `dbprofile` — backend under test (e.g. `mongodb`).
- `bench_suite` — name/label of the benchmark suite/campaign.
- `nuxeonodes`, `esnodes` — cluster sizing.
- `distribution` — Nuxeo distribution/version tested.
- `import_docs` — number of documents created by mass import (the base document count for the whole run).
- `reindex_docs` — total documents in the repository at reindex time (import_docs + any docs created by other simulations); this is the closest thing to "total number of docs" for the run and is shown as "Number of documents" in Configuration.
- `versions_total` / `versions_retained`, `binaries_total` / `binaries_retained` — orphan versions/binaries before/after Full GC.
- `import_dps`, `reindex_dps` — computed throughput in docs/sec (see above).

## Rendering: where the math/overview lives

- `layouts/bench/single.html` — full benchmark report page. The **Overview** table (near the top) pulls straight from `data/bench/<ID>.yml` via `(index .Site.Data.bench $data).<field>`, no computation happens in the template itself except conditional "NA" fallback when a simulation didn't run (e.g. `move_duration`, `search_rps`, `cleanup_duration`, `fullgc_duration` can be nil for older/lighter runs). Overview columns map to fields as:
  - Duration → `benchmark_duration`
  - Import → `import_dps` (linked to `#massimport`)
  - Move → `move_duration`
  - Create → `create_rps` / `create_avg` / `create_std`
  - Read → `nav_rps` / `nav_avg` / `nav_std`
  - Search → `search_rps` / `search_avg` / `search_std`
  - Update → `update_rps` / `update_avg` / `update_std`
  - CRUD → `crud_rps` / `crud_avg` / `crud_std`
  - Reindexing → `reindex_dps`
  - Cleanup → `cleanup_duration`
  - FullGC → `fullgc_duration`
  - Further down the same page, the "Details" section repeats these per-simulation with more fields (count, error %, concurrency, min/p50/p95, async residual duration) plus links to the Gatling/Datadog reports.
- `layouts/bench/summary_row.html` — one table row per benchmark, used on listing pages (e.g. per-suite/comparison tables). Same fields/columns as the Overview table above, condensed.
- `layouts/custom/*.html` — equivalent templates for custom (ad-hoc) benchmarks under `data/custombench/`.
- No computation happens in Hugo templates beyond nil-checks; all math (dps, durations) is precomputed by `add_build_to_site.sh` / `update_data()` or comes straight from the Gatling simulation.yml/log parsing that produced `data.yml` upstream (in the Nuxeo CI job, outside this repo).

## Understanding the simulations

See `content/scenarios.md` for the authoritative description of each Gatling simulation (source: [nuxeo-server-gatling-tests](https://github.com/nuxeo/nuxeo/tree/master/ftests/nuxeo-server-gatling-tests)) and the metrics glossary (Throughput sync, Duration sync, Residual duration async, Total duration, p50, p95, etc.). Read it before interpreting `_avg`/`_duration`/`*async*` fields.

Summary of simulations and their corresponding data.yml prefix:

| Simulation | data.yml prefix | Notes |
|---|---|---|
| Mass import (nuxeo-platform-importer) | `import_` | Single Nuxeo node; docs + attachment to S3, fulltext extracted/indexed |
| Move folder | `move_` | Moves the mass-imported folder |
| Bulk update (single command) | `bulk_` | Bulk Service, one command updates all imported docs |
| Multi bulk update | `mbulk_` | Many small Bulk Service commands on random folders |
| CSV export | `exportcsv_` | Bulk Service export of imported docs to CSV |
| Create document (REST) | `create_` / `createasync_` | No attachment, from CSV |
| Read (REST) | `nav_` | Random folders/docs, various metadata |
| Navigation (JSF) | `navjsf_` | Web UI navigation, optional/legacy |
| Search (REST) | `search_` | Fulltext + NXQL search |
| Update (REST) | `update_` / `updateasync_` | |
| CRUD (REST) | `crud_` / `crudasync_` | Create/Read/Update/Delete on previously imported docs |
| Benchmark mixing actions | `bench_` | JSF navigation + REST read/update, uses think time |
| Reindex repository | `reindex_` | Drop/recreate Elasticsearch index |
| Cleanup | `cleanup_` | Deletes workspace/users/group (versions remain as orphans) |
| Full GC | `fullgc_` | GC of orphan versions then orphan binaries |

## Quick recipe for an agent

To answer "what was the import rate / duration / total docs / Full GC time for `platform-1402`":
1. Read `data/bench/platform-1402.yml`.
2. Duration → `benchmark_duration`; Import rate → `import_dps` (docs/s), `import_duration` (s); Total docs → `reindex_docs` (or `import_docs` for just the mass-imported set); Full GC → `fullgc_duration` (s), with before/after counts in `versions_total`/`versions_retained` and `binaries_total`/`binaries_retained`.
3. Cross-check field meaning against `content/scenarios.md` and the prefix table above.
4. For rendering/formatting semantics, check `layouts/bench/single.html` (Overview table + Details sections).
