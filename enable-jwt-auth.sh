#!/usr/bin/env bash

. config.sh



# Vault can be configured to trust our OIDC Discovery URL, but it requires https.
# Since aap-dev doesn't support that, we're using 'caddy' to proxy. We need to provide
# the CA PEM, so we'll concatenate Caddy's Root CA and intermediate and provide that to vault

CADDY_APP_DATADIR=$(caddy environ | grep "caddy.AppDataDir" | cut -d '=' -f 2)
CADDY_CA_DIR="$CADDY_APP_DATADIR/pki/authorities/local"
OIDC_DISCOVERY_CA_PEM_FILE="$(mktemp).pem"
cat "$CADDY_CA_DIR/root.crt" "$CADDY_CA_DIR/intermediate.crt" > $OIDC_DISCOVERY_CA_PEM_FILE

set -x

# Enable the jwt auth backend for vault at auth/jwt
vault auth enable jwt

# Configure the JWT backend with our proxied OIDC Discovery endpoint and CA Certs
# Vault will use this discovery endpoint to find the JWKS.
# CA Cert is needed because vault's JWT backend will always verify certificates
# (and for self-signed, verification fails if cert does not include subjectAltName)
#
# The discovery url MUST match the issuer (so no trailing / if issuer has no trailing /)
# and vault will append .well-known/openid-configuration to this
vault write auth/jwt/config \
  oidc_discovery_url="https://localhost/o" \
  oidc_discovery_ca_pem=@"$OIDC_DISCOVERY_CA_PEM_FILE"

