#!/bin/bash
set -ex
export PATH=$PATH:/opt/keycloak/bin

REALM_NAME="test"

kcadm.sh config credentials --server http://localhost:8080/ --realm master --user admin --password admin

if kcadm.sh get realms/${REALM_NAME} | grep -q ${REALM_NAME}; then
  kcadm.sh delete realms/${REALM_NAME} > /dev/null
  echo -e "Successfully Deleted the Client and Realm\n"
fi

kcadm.sh create realms -s realm=${REALM_NAME} -s enabled=true -s registrationAllowed=true

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
    "post.logout.redirect.uris": "+"
  }
}
EOF
)
echo "INFO: Created new client 'openid-vue': ${CID}"

FLOWID=$(kcadm.sh create authentication/flows -r $REALM_NAME -i -f - <<EOF
{
  "alias" : "browser plus step-up",
  "description" : "",
  "providerId" : "basic-flow",
  "topLevel" : true,
  "builtIn" : false,
  "authenticationExecutions" : [ {
    "authenticator" : "auth-cookie",
    "authenticatorFlow" : false,
    "requirement" : "ALTERNATIVE",
    "priority" : 0,
    "autheticatorFlow" : false,
    "userSetupAllowed" : false
  }, {
    "authenticatorFlow" : true,
    "requirement" : "ALTERNATIVE",
    "priority" : 1,
    "autheticatorFlow" : true,
    "flowAlias" : "Auth Flow",
    "userSetupAllowed" : false
  } ]
}
EOF
)

echo "INFO: Created new flow: ${FLOWID}"

kcadm.sh create authentication/executions -r $REALM_NAME -i -f - <<EOF
{
  "requirement" : "ALTERNATIVE",
  "displayName" : "Cookie",
  "requirementChoices" : [ "REQUIRED", "ALTERNATIVE", "DISABLED" ],
  "configurable" : false,
  "providerId" : "auth-cookie",
  "level" : 0,
  "index" : 0,
  "priority" : 0
}
EOF
