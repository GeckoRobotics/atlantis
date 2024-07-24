#!/usr/bin/env bash

set -e

METADATA_ENDPOINT="http://metadata.google.internal/computeMetadata/v1/instance"

function get_accesstoken() {
	curl -s $METADATA_ENDPOINT/service-accounts/default/token -H "Metadata-Flavor: Google" | python -c "import json,sys;obj=json.load(sys.stdin);print(obj['access_token'])"
}

function get_secret() {
	curl "https://secretmanager.googleapis.com/v1/projects/${1}/secrets/${2}/versions/latest:access" --request "GET" -H "authorization: Bearer $3" -H "content-type: application/json" | python -c "import json,sys;obj=json.load(sys.stdin);print(obj['payload']['data'])" | base64 -d
}

ACCESS_TOKEN="$(get_accesstoken)"

ATLANTIS_GH_APP_KEY_FILE="$(mktemp)"
export ATLANTIS_GH_APP_KEY_FILE
get_secret gecko-enterprise-admin github-atlantis-app-key-file "$ACCESS_TOKEN" >"$ATLANTIS_GH_APP_KEY_FILE"

ATLANTIS_GH_WEBHOOK_SECRET=$(get_secret gecko-enterprise-admin github-atlantis-webhook-secret "$ACCESS_TOKEN")
export ATLANTIS_GH_WEBHOOK_SECRET

./docker-entrypoint.sh "$@"
