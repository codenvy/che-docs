## Eclipse Che documentation

Che docs use Jekyll to convert `.adoc` (AsciiDoc) files into HTML pages. Docs are published at [https://www.eclipse.org/che/docs](https://www.eclipse.org/che/docs/). Updates are synced with a release cycle.

## Build and preview

### Building online
[![Contribute](https://che.openshift.io/factory/resources/factory-contribute.svg)](https://che.openshift.io/f?url=https://github.com/eclipse/che-docs)

### Building locally

Use a `run.sh` script in the root of the repo to build using a Docker image. The scipts runs a Docker image, mounts sources, and starts Jekyll. Docs are available at `localhost:4000`. Jekyll watches for changes in `.adoc` files and re-generates resources, so you can preview changes live.

To run the script:

* Execute the script from the command line:
```
$ bash run.sh    
```

* Open `http://localhost:4000/` in your browser.

## Adding new pages
Che documentation follows guidelines of the [Modular Documentation initiative](https://redhat-documentation.github.io/modular-docs/)

Use `newdoc` to generate templates for the new documentation.
To learn more about the script: [`newdoc` GitHub repository](https://github.com/redhat-documentation/tools/tree/master/newdoc)

### Using `newdoc` from the `che-docs` container
`newdoc` is built into the `che-docs` container.

To generate new documentation module with the script, execute the `run.sh` script from the `che-docs` root git directory:

* Create a new assembly in a directory `directory_name` <sup id="a1">[directories](#f1)</sup>, with a title `your_title`

```
$ bash run.sh -newassembly <directory_name> <your_title>    
```

* Create a new concept in a directory `directory_name` <sup id="a1">[directories](#f1)</sup>, with a title `your_title` 
```
$ bash run.sh -newconcept  <directory_name> <your_title>       
```

* Create a new procedure in a directory `directory_name` <sup id="a1">[directories](#f1)</sup>, with a title `your_title`
```
$ bash run.sh -newprocedure  <directory_name> <your_title>     
```

* Create a new reference in a directory `directory_name` <sup id="a1">[directories](#f1)</sup>, with a title `your_title`
```
$ bash run.sh -newreference <directory_name> <your_title>
```

## Placing new documentation

To add a new page, create an `.adoc` file in `src/main/pages/che-<version>/<directory_name>`<sup id="a2">[versions](#f1)<sup id="a1">[directories](#f1) 

<b id="f2">Versions: </b>
* `che-6` - Eclipse Che 6 content. Note that Che 6 is deprecated. 
8 `che-7` - Eclipse Che 7 content, including y-streams and z-streams.   

<b id="f1">Available directories: </b> 
* overview - introductory section
* end-user-guide - documentation for developers: navigating dashboard, working in Che-Theia, and so on 
* installation-guide - installation guides
* administration-guide - documentation for administrators of the clusters: configuring Che on a cluster, managing users, monitoring resources, security and data recovery 
* contributor-guide - how to develop plug-ins for Che, add new debuggers, languages, and so on
* extensions - documentation about extensions for Che, such as Eclipse Che4z, OpenShift Connector 
[↩](#a1)

If there is no directory that fits a topic of your document, create a new one. 

## Adding Jekyll metadata

Make sure to include all the necessary metadata, so that a generated HTML page has the expected name, title, and keywords. For example:

```yaml
---
title: "Installing single-user Che on Docker"
keywords: docker, installation
tags: [installation, docker]
sidebar: che_6_docs
permalink: docker-single-user.html
folder: setup
---
```
## Formatting in Asciidoc
Che docs use Asciidoc for formatting. See [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/) for syntax and general help with AsciiDoc.

### Testing with `test-adoc`  
`test-adoc` is built into the `che-docs` container.

## How to get support

* **GitHub issue:** [![New questions](https://img.shields.io/badge/New-question-blue.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/question)
[![New bug](https://img.shields.io/badge/New-bug-red.svg?style=flat-curved)](https://github.com/eclipse/che/issues/new?labels=area/doc,kind/bug)

* **Public Chat:** Join the public [eclipse-che](https://mattermost.eclipse.org/eclipse/channels/eclipse-che) Mattermost channel to talk to the community and contributors

## How to contribute

We love pull requests and appreciate contributions that make docs more helpful for users. See the [Contribution guide](https://github.com/eclipse/che#contributing).
