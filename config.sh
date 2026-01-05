export VAULT_ADDR=$(jq -r '.nodes[0].api_address' config/cluster.json)
export VAULT_CACERT=$(jq -r '.ca_cert_path' config/cluster.json)
