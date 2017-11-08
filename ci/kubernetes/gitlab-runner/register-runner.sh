#! /bin/bash

REGISTRATION_TOKEN='xPDu2F2N-zWbPvFXhuRL'

curl -v -H "Content-Type: application/json" -X POST -d "{"'"'"token"'"'":"'"'"${REGISTRATION_TOKEN}"'"'","'"'"description"'"'":"'"'"${1}"'"'"}" 'https://gitlab.udd.bogops.io/ci/api/v1/runners/register'
