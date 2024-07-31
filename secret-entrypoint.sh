#!/usr/bin/env bash

set -e

METADATA_ENDPOINT="http://metadata.google.internal/computeMetadata/v1/instance"

function get_accesstoken() {
	curl -s $METADATA_ENDPOINT/service-accounts/default/token -H "Metadata-Flavor: Google" | python3 -c "import json,sys;obj=json.load(sys.stdin);print(obj['access_token'])"
}

function get_secret() {
	curl "https://secretmanager.googleapis.com/v1/projects/${1}/secrets/${2}/versions/latest:access" --request "GET" -H "authorization: Bearer $3" -H "content-type: application/json" | python3 -c "import json,sys;obj=json.load(sys.stdin);print(obj['payload']['data'])" | base64 -d
}

echo "Getting access token..."

if ! [ "$RUNNING_ON" == "local" ]; then
	ACCESS_TOKEN="$(get_accesstoken)"
fi

echo "Got access token"

# For local development, mount the keyfile as a volume and set ATLANTIS_GH_APP_KEY_FILE
ATLANTIS_GH_APP_KEY_FILE="${ATLANTIS_GH_APP_KEY_FILE:-$(mktemp)}"
export ATLANTIS_GH_APP_KEY_FILE

echo "Getting github app key file secret..."

if ! [ "$RUNNING_ON" == "local" ]; then
	get_secret gecko-admin atlantis-github-app-key-file-secret "$ACCESS_TOKEN" >"$ATLANTIS_GH_APP_KEY_FILE"
fi

echo "Got github app key file secret"

echo "Getting github webhook secret..."

# For local development, set ATLANTIS_GH_WEBHOOK_SECRET
if ! [ "$RUNNING_ON" == "local" ]; then
	ATLANTIS_GH_WEBHOOK_SECRET="$(get_secret gecko-admin atlantis-github-webhook-secret "$ACCESS_TOKEN")"
fi

echo "Got github webhook secret"
export ATLANTIS_GH_WEBHOOK_SECRET

/usr/local/bin/docker-entrypoint.sh "$@"
