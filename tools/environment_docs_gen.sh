#!/bin/bash
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -o pipefail

CURRENT_VERSION=""
RAW_CONTENT=""
NEWLINE=$'\n'
NEWLINEx2="$NEWLINE$NEWLINE"
TABLE_HEADER="$NEWLINE,=== $NEWLINE Environment Variable Name,Default value, Description $NEWLINE"
TABLE_FOOTER=",=== $NEWLINEx2"
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")/.." ; pwd -P )
BUFF=""
OUTPUT_PATH="$PARENT_PATH/modules/installation-guide/examples/system-variables.adoc"

fetch_current_version() {
  echo "Trying to read current product version from $PARENT_PATH/antora.yml..." >&2
  # remove spaces, single and double quotes from the value of prod-ver, then append .x
  CURRENT_VERSION=$(grep 'prod-ver:' "$PARENT_PATH/antora.yml" | cut -d: -f2 | tr -d " '\"").x
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read version from $PARENT_PATH/antora.yml" >&2
    exit 1
  fi
  if [[ "$CURRENT_VERSION" == *-SNAPSHOT ]]; then
     CURRENT_VERSION="master"
  fi
  echo "Detected version: $CURRENT_VERSION" >&2
}


fetch_conf_files_content() {
  echo "Fetching property files content from GitHub..." >&2
  CHE_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse-che/che-server/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/che.properties"
  RAW_CONTENT=$(curl -sf "$CHE_PROPERTIES_URL")
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read che.properties from URL $CHE_PROPERTIES_URL" >&2
    exit 1
  fi
  MULTIUSER_PROPERTIES_URL="https://raw.githubusercontent.com/eclipse-che/che-server/$CURRENT_VERSION/assembly/assembly-wsmaster-war/src/main/webapp/WEB-INF/classes/che/multiuser.properties"
  RAW_CONTENT="$RAW_CONTENT $(curl -sf "$MULTIUSER_PROPERTIES_URL")"
  if [ $? -ne 0 ]; then
    echo "Failure: Cannot read multiuser.properties from URL $MULTIUSER_PROPERTIES_URL" >&2
    exit 1
  fi
  echo "Fetching content done. Trying to parse it." >&2
}

parse_content() {
  while read -r LINE
  do
    if [[ $LINE == '##'* ]]; then                       # line starting with two or more #s means new topic is started
      if [[ -n $TOPIC ]]; then
        BUFF="$BUFF$TABLE_FOOTER"                       # topic changes, closing the table
      fi
      TOPIC="${LINE//#}"                                # read topic, stripping #s
      TOPIC="${TOPIC/ }"                                # trim first space
      TOPICID="${TOPIC// /-}"                                # create topic ID
      TOPICID="$(sed 's|-\{2,\}|-|g; s|[\"\/=,.<>?!;:()*]||g; s|\(.*\)|[id="\L\1"]|;s|prod-short|prod-id-short|' <<< $TOPICID)"
                                                        # replace spaces with dashes, create topic ID, convert to lowercase chars
                                                        # remove non alpha-num, wrap in AsciiDoc ID markup
      echo "   Found begin of topic: $TOPIC" >&2
      BUFF="${BUFF}${TOPICID}$NEWLINE= ${TOPIC}$NEWLINEx2.${TOPIC} $TABLE_HEADER $NEWLINE"      # new topic and table header
    elif [[ $LINE == '#'* ]] && [[ -n $TOPIC ]]; then   # line starting with single # means property description (can be multi-line)
      TRIM_LINE=${LINE/\#}                              # read description, stripping first #
      DESCR_BUFF="$DESCR_BUFF${TRIM_LINE}"              # collect all description lines into buffer
    elif [[ -z $LINE ]] && [[ -n $TOPIC ]]; then
      DESCR_BUFF=""                                     # empty line is a separator -> cleanup description and property name + value
      KEY=""
      VALUE=""
    elif [[ -n $TOPIC ]]; then                          # non-empty line after any topic that doesn't start with # -> treat as property line
      IFS=$'=' read -r KEY VALUE <<< "$LINE"            # property split into key and value
      ENV=${KEY^^}                                      # capitalize property name
      ENV="\`+${ENV//_/__}+\`"                          # replace single underscores with double
      ENV=${ENV//./_}                                   # replace dots with single underscore
      VALUE="${VALUE/ }"                                # trim first space
      VALUE="\`+${VALUE}+\`"                            # make sure asciidoc doesn't mix it up with attributes
      VALUE="${VALUE/\`++\`}"                           # remove empty value `++`
      
      DESCR_BUFF="$(sed 's|\${\([^}]*\)}|$++{\1}++|g' <<< $DESCR_BUFF)"   # make sure asciidoc doesn't mix it up with attributes
      DESCR_BUFF="$(sed 's|\(Eclipse \)\?\bChe\b|{prod-short}|g' <<< $DESCR_BUFF)"   # (Eclipse) Che -> {prod-short}
      DESCR_BUFF="$(sed -E 's| http:| \\http:|g' <<< $DESCR_BUFF)"   # Deactivate http links
      DESCR_BUFF="$(sed -E 's| https:| \\https:|g' <<< $DESCR_BUFF)"   # Deactivate http links
      DESCR_BUFF="$(sed -E 's|https://docs.openshift.com/container-platform/latest/architecture/additional_concepts/storage.html#pv-access-modes|https://docs.openshift.com/container-platform/4.4/storage/understanding-persistent-storage.html|' <<< $DESCR_BUFF)"   # Fix broken link
      DESCR_BUFF="$(sed -E 's|https://docs.openshift.com/container-platform/latest/dev_guide/compute_resources.html#dev-compute-resources|https://docs.openshift.com/container-platform/4.4/storage/understanding-persistent-storage.html|' <<< $DESCR_BUFF)"   # Fix broken link
      DESCR_BUFF="$(sed -E 's|https://www.keycloak.org/docs/3.3/server_admin/topics/identity-broker/social/openshift.html|https://www.keycloak.org/docs/latest/server_admin/index.html#openshift-4|' <<< $DESCR_BUFF)"   # Fix broken link
      DESCR_BUFF="$(sed -E 's|k8s|{orch-name}|g' <<< $DESCR_BUFF)"   # k8s to {orch-name}
      DESCR_BUFF="$(sed -E 's| openshift| {ocp}|g' <<< $DESCR_BUFF)"   # k8s to {orch-name}
      DESCR_BUFF="$(sed -E 's|che-host|prod-host|g' <<< $DESCR_BUFF)"   # fix missing attribute che-host
      DESCR_BUFF="$(sed -E 's|\{WORKSPACE_ID|\\\{WORKSPACE_ID|g' <<< $DESCR_BUFF)"   # fix missing attribute WORKSPACE_ID
      DESCR_BUFF="$(sed -E 's|\{generated_8_chars|\\\{generated_8_chars|g' <<< $DESCR_BUFF)"   # fix missing attribute generated_8_chars

      DESCR_BUFF="${DESCR_BUFF/ }"                      # trim first space
      BUFF="$BUFF $ENV,\"$VALUE\",\"${DESCR_BUFF//\"/\'}\" $NEWLINE"   # apply key value and description buffer
    fi
  done <<< "$RAW_CONTENT"
  BUFF="$BUFF$TABLE_FOOTER"                             # close last table
  BUFF="pass:[<!-- vale off -->]

$BUFF" 
  echo "$BUFF" > "$OUTPUT_PATH"                         # flush buffer into file
  echo "Processing done. Output file is $OUTPUT_PATH" >&2
}

fetch_current_version
fetch_conf_files_content
parse_content
