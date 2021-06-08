#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -o pipefail
set -e

CURRENT_VERSION=""
PRODUCT=""
RAW_CONTENT=""
NEWLINE=$'\n'
NEWLINEx2="$NEWLINE$NEWLINE"
TABLE_HEADER="$NEWLINE[cols=\"2,5\", options=\"header\"]$NEWLINE:=== $NEWLINE Property: Description $NEWLINE"
TABLE_FOOTER=":=== $NEWLINEx2"
PARENT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd -P)
BUFF=""
OUTPUT_PATH="$PARENT_PATH/modules/installation-guide/examples/checluster-properties.adoc"

fetch_current_version() {
  echo "Trying to read current product version from $PARENT_PATH/antora.yml..." >&2
  # remove spaces, single and double quotes from the value of prod-ver, then append x.
  CURRENT_VERSION=$(yq -M '.asciidoc.attributes."prod-ver"' "$PARENT_PATH/antora.yml" | tr -d " '\"" ).x
  if [[ "$CURRENT_VERSION" == *-SNAPSHOT ]]; then
    CURRENT_VERSION="master"
  fi
  echo "Detected version: $CURRENT_VERSION" >&2
}

fetch_product_name() {
  echo "Trying to read product name from $PARENT_PATH/antora.yml..." >&2
  PRODUCT=$(yq -rM '.asciidoc.attributes."prod-id-short"' "$PARENT_PATH/antora.yml")
  echo "Detected product: $PRODUCT" >&2
}

fetch_conf_files_content() {
  echo "Fetching property files content from GitHub..." >&2

  if [[ $PRODUCT == "che" ]]; then
    CHECLUSTER_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse/che-operator/$CURRENT_VERSION/deploy/crds/org_v1_che_crd.yaml"
  else
    CHECLUSTER_PROPERTIES_URL="https://raw.githubusercontent.com/redhat-developer/codeready-workspaces-operator/crw-$CURRENT_VERSION-rhel-8/deploy/crds/org_v1_che_crd.yaml"
  fi

  RAW_CONTENT=$(curl -sf "$CHECLUSTER_PROPERTIES_URL")
  local crdVersion=$(echo "$RAW_CONTENT" | yq -r '.apiVersion')
  echo "Fetching content done. CRD version: $crdVersion. Trying to parse it." >&2
}

parse_content() {
  parse_section "server" "\`CheCluster\` Custom Resource \`server\` settings, related to the {prod-short} server component."
  parse_section "database" "\`CheCluster\` Custom Resource \`database\` configuration settings related to the database used by {prod-short}."
  parse_section "auth" "Custom Resource \`auth\` configuration settings related to authentication used by {prod-short}."
  parse_section "storage" "\`CheCluster\` Custom Resource \`storage\` configuration settings related to persistent storage used by {prod-short}."
  if [[ $PRODUCT == "che" ]]; then
    parse_section "k8s" "\`CheCluster\` Custom Resource \`k8s\` configuration settings specific to {prod-short} installations on {platforms-name}."
  fi
  parse_section "metrics" "\`CheCluster\` Custom Resource \`metrics\` settings, related to the {prod-short} metrics collection used by {prod-short}."
  parse_section "status" "\`CheCluster\` Custom Resource \`status\` defines the observed state of {prod-short} installation"
  BUFF="pass:[<!-- vale off -->]

$BUFF" 
  echo "$BUFF" > "$OUTPUT_PATH"
  echo "Processing done. Output file is $OUTPUT_PATH" >&2
}


parse_section() {
  local section
  local sectionName=$1
  local id="[id=\"checluster-custom-resource-$sectionName-settings_{context}\"]"
  local caption=$2
  local crdVersion=$(echo "$RAW_CONTENT" | yq -r '.apiVersion')
  echo "Parsing section: "$sectionName

  if [[ $sectionName == "status" ]]; then
    if [[ $crdVersion == "apiextensions.k8s.io/v1beta1" ]]; then
      section=$(echo "$RAW_CONTENT" | yq -M '.spec.validation.openAPIV3Schema.properties.status')
    else
      section=$(echo "$RAW_CONTENT" | yq -M '.spec.versions[] | select(.name == "v1") | .schema.openAPIV3Schema.properties.status')
    fi
  else
    if [[ $crdVersion == "apiextensions.k8s.io/v1beta1" ]]; then
      section=$(echo "$RAW_CONTENT" | yq -M '.spec.validation.openAPIV3Schema.properties.spec.properties.'"$sectionName")
    else
      section=$(echo "$RAW_CONTENT" | yq -M '.spec.versions[] | select(.name == "v1") | .schema.openAPIV3Schema.properties.spec.properties.'"$sectionName")
    fi
  fi

  local properties=(
    $(echo "$section" | yq -M '.properties | keys[]' )
  )

  BUFF="$BUFF$id$NEWLINE"
  BUFF="$BUFF.$caption$NEWLINE"
  BUFF="$BUFF$TABLE_HEADER"
  for PROP in "${properties[@]}"
  do
    PROP="${PROP//\"}"
    DESCR_BUFF=$(echo "$section" | yq -M '.properties.'"$PROP"'.description')
    DESCR_BUFF="${DESCR_BUFF//\"}"
    DESCR_BUFF="${DESCR_BUFF//:/\\:}"
    DESCR_BUFF="$(sed 's|Eclipse Che|{prod-short}|g' <<< $DESCR_BUFF)"
    BUFF="$BUFF${PROP}: ${DESCR_BUFF}$NEWLINE"
  done
  BUFF="$BUFF$TABLE_FOOTER"
}

fetch_current_version
fetch_product_name
fetch_conf_files_content
parse_content
