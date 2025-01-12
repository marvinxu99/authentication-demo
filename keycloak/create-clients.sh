#!/bin/bash
set -ex
export PATH=$PATH:/opt/keycloak/bin

REALM_NAME="test"

kcadm.sh config credentials --server http://localhost:8080/ --realm master --user admin --password admin

if kcadm.sh get realms/${REALM_NAME} | grep -q ${REALM_NAME}; then
  kcadm.sh delete realms/${REALM_NAME} > /dev/null
  echo -e "Successfully Deleted the Client and Realm\n"
fi

kcadm.sh create realms -s realm=test -s enabled=true

kcadm.sh create users -s username=test -s enabled=true -s firstName=Theo -s lastName=Tester -s email=test@example.com -r $REALM_NAME
kcadm.sh set-password -r $REALM_NAME --username test --new-password test-password

CID=$(kcadm.sh create clients -r $REALM_NAME -i -f - <<EOF
{
  "clientId": "openid-vue",
  "enabled": true,
  "rootUrl": "http://localhost:5173/",
  "baseUrl": "http://localhost:5173/",
  "redirectUris": [
    "http://localhost:5173/*"
  ],
  "webOrigins": [
    "+"
  ],
  "publicClient": true,
  "protocol": "openid-connect",
  "attributes": {
    "post.logout.redirect.uris": "+",
    "dpop.bound.access.tokens": "true"
  }
}
EOF
)
echo "INFO: Created new client 'openid-vue': ${CID}"
