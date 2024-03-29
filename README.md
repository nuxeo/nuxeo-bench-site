# Nuxeo Benchmark Reference Site

This is the reference benchmark static site: https://benchmarks.nuxeo.com/

The site is generated by [Hugo](https://gohugo.io/).

Benchmarks are run by the continuous integration (Jenkins) and commit the results as new content and data to this repository.

Commit to this repository trigger another job to build and publish the site to a S3 bucket, this s3 bucket is exposed as the reference benchmark site by CloudFront.

The site can be edited locally using Hugo, from this repository once you have installed Hugo:

```bash
hugo serve -t hyde --disableFastRender
```

Then go to http://localhost:1313/

Note that the git repo only contains the layout and a minimal information per benchmark result (a markdown + yaml files).
The detailed reports like Gatling reports or monitoring are saved in another S3 bucket, out of the git repository.

## Styling

To take advantage of standard Nuxeo styling, we use SCSS.

```bash
npx sass --style=compressed assets/scss/:themes/hyde/static/css/dist/
```

For development, the source can be watched

```bash
npx sass --watch assets/scss/:themes/hyde/static/css/dist/
```

# About Nuxeo

Nuxeo provides a modular, extensible, open source
[platform for enterprise content management](http://www.nuxeo.com/products/content-management-platform) used by organizations worldwide to power business processes and content repositories in the area of
[document management](http://www.nuxeo.com/solutions/document-management),
[digital asset management](http://www.nuxeo.com/solutions/digital-asset-management),
[case management](http://www.nuxeo.com/case-management) and [knowledge management](http://www.nuxeo.com/solutions/advanced-knowledge-base/). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and top notch performance.

More information on: <http://www.nuxeo.com/>


# Nuxeo Benchmarks Build and Deploy Workflow

This GitHub Actions workflow automates the build and deployment process for the Nuxeo Benchmarks site. It utilizes Hugo for site generation, uploads artifacts, and deploys the site to a specified server using rsync.

## Workflow Overview:

### 1. Clean Directory

This step removes the existing "resources" and "public" directories to ensure a clean build.

### 2. Checkout Code

This step checks out the source code from the repository.

### 3. Build Site with Hugo

The Nuxeo Benchmarks site is built using Hugo with a specific theme and version.

### 4. Upload Artifact

The built site is uploaded as an artifact for further reference.

### 5. Set up SSH

This step configures the SSH agent with the private key required for server deployment.

### 6. Rsync to Server

The final step deploys the Nuxeo Benchmarks site to the specified server using rsync.

## Variables

The following variables are required for this workflow:

- `SERVER_SSH_PRIVATE_KEY`: The private SSH key used for authentication with the benchmarks deployment server.

- `SERVER_USERNAME`: The username used to connect to the benchmarks deployment server.

- `SERVER_IP`: The IP address or hostname of the benchmarks deployment server.

- 'Values for current Variables are kept in LastPass.'

## Usage

Before running the workflow, ensure that the necessary secrets are added to your GitHub repository.

1. Add `SERVER_SSH_PRIVATE_KEY`, `SERVER_USERNAME`, and `SERVER_IP` as secrets in the GitHub repository.

2. Push changes to the `master` branch to trigger the workflow.


