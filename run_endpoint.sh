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

# load secrets
load_secrets

# run fipsinstall to create the fipsmodule.cnf
/opt/openssl/bin/openssl fipsinstall -module /opt/openssl/lib64/ossl-modules/fips.so -out /opt/openssl/ssl/fipsmodule.cnf

# and stitch it into our config file
sed -i -e"s/# \.include fipsmodule.cnf/\.include fipsmodule.cnf/" /opt/openssl/ssl/openssl.cnf
sed -i -e"s/# fips = fips_sect/fips = fips_sect/" /opt/openssl/ssl/openssl.cnf

# activate the default provider as well
sed -i -e"s/# activate = 1/activate = 1/" /opt/openssl/ssl/openssl.cnf

# Now just run a shell so users can run the acvp_app
exec /bin/bash
