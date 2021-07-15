# Add here a title for your PR

<!-- 
Please use one of the following prefixes for the title:
docs: Documentation not including procedures. Engineering review is mandatory.
procedures: Documentation including procedures. Testing procedures is mandatory. Engineering and QE review is mandatory (Engineering can review on behalf of QE). 
chore: Choreography, release, tooling, version upgrades.
fix: Fix build, language, links, or metadata.
-->

<!-- Read our [Contribution guide](https://github.com/eclipse/che-docs/blob/master/CONTRIBUTING.adoc) before submitting a PR. -->

## What does this PR do?

## What issues does this PR fix or reference?

## Specify the version of the product this PR applies to

## Pull Request Checklist

The author and the reviewers validate the content of this Pull Request with this checklist, in addition to the [automated tests](code_review_checklist.adoc).

- Any procedure:
  - [ ] Successfully tested.
  - [ ] Describes a scenario already covered by QE tests, otherwise Che QE team has acknowledged an issue.
- Any page or link rename:
  - [ ] The page contains a redirection for the previous URL.
  - Propagate the URL change in:
    - [ ] Dashboard [default branding data](https://github.com/eclipse-che/che-dashboard/blob/main/src/services/bootstrap/branding.constant.ts)
    - [ ] Chectl [constants.ts](https://github.com/che-incubator/chectl/blob/master/src/constants.ts)
- [ ] Builds on [Eclipse Che hosted by Red Hat](https://workspaces.openshift.com).
- [ ] *`Validate language on files added or modified`* step reports no vale warnings.
