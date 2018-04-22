#!/bin/bash -eu

. "$(dirname $0)"/export-director-metadata

command=""
if [ "$BBR_OPERATION" == "director" ]; then
	command="director --host "${BOSH_ADDRESS}"
elif [ "$BBR_OPERATION" == "deployment" ]; then
	command="deployment -d ${ERT_DEPLOYMENT_NAME} -t ${BOSH_ADDRESS} --ca-cert ${BOSH_CA_CERT_PATH}"
else
  echo "BBR_OPERATION can either be deployment or director"
  exit 1
fi

om_cmd curl -p /api/v0/deployed/director/credentials/bbr_ssh_credentials > bbr_keys.json
BOSH_PRIVATE_KEY=$(jq -r '.credential.value.private_key_pem' bbr_keys.json)

./binary/bbr ${command} \
--username bbr \
--private-key-path <(echo "${BBR_PRIVATE_KEY}") \
restore \
--artifact-path ./archive
