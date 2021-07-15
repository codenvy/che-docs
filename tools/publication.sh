#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -ex

# These 2 scripts run in current branch.
# We need to run them from the publication branch context (7.y.x).
# They should be run by make-release.sh when creating or updating the 7.y.x branch.
#./tools/environment_docs_gen.sh
#./tools/checluster_docs_gen.sh

CI=true antora generate antora-playbook-publication.yml --stacktrace