#!/bin/bash

# Check to ensure our secrets are in the proper place
check_secret() {
    local secret_file=/secrets/$1

    if [ ! -f $secret_file ]
    then
        echo "$secret_file not found"
        exit 1
    fi
}

load_secrets() {
    check_secret acv_ca_file
    export ACV_CA_FILE=/secrets/acv_ca_file
    check_secret acv_key_file
    export ACV_KEY_FILE=/secrets/acv_key_file
    check_secret acv_cert_file
    export ACV_CERT_FILE=/secrets/acv_cert_file
    check_secret acv_totp_seed
    export ACV_TOTP_SEED=$(cat /secrets/acv_totp_seed)
}

# set non-secret settings

export ACV_URI_PREFIX=/acvp/v1/
export ACV_API_CONTEXT=acvp/
export ACV_PORT=443
export ACV_SERVER=demo.acvts.nist.gov
load_secrets

exec /bin/bash
