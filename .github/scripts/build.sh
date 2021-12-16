#!/bin/bash

METADATA_FILES=$(find -name metadata.json | paste -sd " ")
ICON_FILES=$(find -name icon.png | paste -sd " ")

mkdir tmp

# create resources archive
if [ ! -z "$ICON_FILES" ]; then
    cd packages
    echo "$ICON_FILES" | sed 's|packages/||g' | xargs zip -9 "../resources.zip"
    cd ..
fi

# create packages and update repo
if [ ! -z "$METADATA_FILES" ]; then
    echo "Generating repo with following packages:"
    echo "$METADATA_FILES" | awk -F'/' '{print $3}'
    echo "$METADATA_FILES" | xargs jq -ns '{ "packages": inputs | . }' > packages.json
fi

jq --arg sha "$(sha256sum packages.json | awk '{ print $1 }')" '.packages.sha256 = $sha' repository.json > tmp/repository.json.0
jq '.packages.update_time_utc = (now | strftime("%d-%m-%Y %T"))' tmp/repository.json.0 > tmp/repository.json.1
jq '.packages.update_timestamp = (now|floor)' tmp/repository.json.1 > tmp/repository.json.2



jq --arg sha "$(sha256sum resources.zip | awk '{ print $1 }')" '.resources.sha256 = $sha' tmp/repository.json.2 > tmp/repository.json.3
jq '.resources.update_time_utc = (now | strftime("%d-%m-%Y %T"))' tmp/repository.json.3 > tmp/repository.json.4
jq '.resources.update_timestamp = (now|floor)' tmp/repository.json.4 > repository.json
