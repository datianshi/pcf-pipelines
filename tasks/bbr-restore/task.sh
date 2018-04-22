#!/bin/bash -eu

. "$(dirname $0)"/export-director-metadata

command=""
if [ "$BBR_OPERATION" == "director" ]; then
	command="director"
elif [ "$BBR_OPERATION" == "deployment" ]; then
  PAS_DEPLOYMENT="$(om_cmd curl -s -p /api/v0/deployed/products | grep cf-)"
  echo "restore deployment: $PAS_DEPLOYMENT"
	command="deployment -d $PAS_DEPLOYMENT"
else
  echo "BBR_OPERATION can either be deployment or director"
  exit 1
fi

om_cmd curl -p /api/v0/deployed/director/credentials/bbr_ssh_credentials > bbr_keys.json
BOSH_PRIVATE_KEY=$(jq -r '.credential.value.private_key_pem' bbr_keys.json)

./binary/bbr $command --host "${BOSH_ADDRESS}" \
--username bbr \
--private-key-path <(echo "${BBR_PRIVATE_KEY}") \
restore \
--artifact-path ./archive
