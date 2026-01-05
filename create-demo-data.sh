#!/usr/bin/env bash

. config.sh

vault write auth/jwt/role/aap-oidc-demo-role -<<EOF
{
  "user_claim": "controller_project_name",
  "bound_audiences": ["oidc-demo-audience"],
  "role_type": "jwt",
  "policies": "aap-oidc-demo-policy",
  "not_before_leeway": 7200,
  "ttl": "300s"
}
EOF

# We need to know the id (accessor) of the JWT auth backend so that we can map policies to its users
JWT_ACCESSOR=$(vault auth list --format json | jq -r '."jwt/".accessor')

# write a policy that allows access to a secret to read a secret for them.
vault policy write aap-oidc-demo-policy - << EOF
path "secret/data/{{ identity.entity.aliases.${JWT_ACCESSOR}.name }}/simple-secret" {
   capabilities = [ "read" ]
}
EOF

# Finally, write some simple secrets at these locations
vault kv put "secret/oidc-demo-project/simple-secret" \
  database_user=controller \
  database_password=vault-secret-password-1

vault kv put "secret/other-project/simple-secret" \
  database_user=oidc_user \
  database_password=jwt-this-down
