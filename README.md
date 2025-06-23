---
title: Update IUCN Global Ecosystem Typology content
author: José R. Ferrer-Paris ([@jrfep](https://github.com/jrfep))
---
# Update IUCN Global Ecosystem Typology content

Scripts to update content of the **IUCN Global Ecosystem Typology** [web site](https://global-ecosystems.org/).

Maintained by [@jrfep](https://github.com/jrfep)

This repository contains documented code to stream line updates to the contents of the IUCN Global Ecosystem Typology (GET).

## Sources of updates 

Initially, the content of the profiles for biomes (level 2) and ecosystem functional groups (level 3) of the typology was updated primarily by Prof. David Keith and coauthors and provided in a word document in format `.docx`. So far there have been three published version:

- version 1.0: appeared in an original, internal IUCN report (including 104 level 3 units)
- version 2.0: appeared in the official [IUCN report](https://doi.org/10.2305/IUCN.CH.2020.13.en) published in 2020 (including 108 level 3 units)
- version 2.1: is published as an appendix of [Keith et al. 2022](https://doi.org/10.1038/s41586-022-05318-4) (including 110 level 3 units)

Minor revisions and updates have been published as minor versions and appeared in the [web site](https://global-ecosystems.org/) or distributed as part of published data sets in a [Zenodo repository](http://doi.org/10.5281/zenodo.3546513).

Starting late in 2024 a GET Scientific Committee evaluates the need for specific updates to the GET. The Committee comprises international experts in terrestrial, freshwater and marine ecosystems and seeks external advice as needed. 

From 2025, annual updates to the GET are planned. Proposed updates will need to go through a nomination and review process. The process is outlined in a document that will be available in the GET website.

## Update process

Initially the content of the website was formatted as Markdown documents in a github repository and updated via `prose.io` or direct commits via `git`. But this presented a challenge to synchronise small edits in the Markdown documents back to the working version in the word document.

A `postgresql` database was set-up to keep control of the valid versions of the text of the profiles, and used as main source to export content to Markdown or XML documents that are distributed with the data sets in Zenodo.

For versions 1.0 through 2.1 the workflow for changes involved:

1. DK provides updated profiles in docx format
2. Text content is inserted into the corresponding tables of the database as new version
3. Scripts are run to update content in database or repositories as needed

Beginning in June 2025 the workflow for changes will be revised, and is expected to include the following steps:

- Identification of update issue
- Check register: 
 - do not proceed if issue addressed in previous proposal
 - proceed otherwise
- Prepare proposal for revision and submit to GET-SC secretariat
- Review by GET-SC
 - include topic specialists if required
 - request further advice and revision of proposal if required
- GET-SC submit recommendations
- GET data hub implements recommendation

## Implementation of updates

See documentation in folder `doc` for sequence of scripts and notebooks to implement different types of updates.