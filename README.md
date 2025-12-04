# OpenSSL ACVP Container

This repository builds a container to be run interactively for use with the acvp_app from https://github.com/cisco/libacvp/tree/main
It is currently meant to build with podman, but should work equally well with docker

## Building
just run `make all`
Note that by default it is configured to create the acvp_app with openssl 3.5.4 as the FIPS module under test

## Running
you can run it with podman/docker directly, or you can run `make run` to start an interactive session in the container
Note you will need to create a few secrets to run it properly
1) ACV_CERT_FILE_SECRET - This secret holds the users certificate for accessing the ACVP server.  Accessible via /secrets/acv_cert_file in the container 
2) ACV_KEY_FILE_SECRET - This secret holds the users private key matching the cert in (1).  Accessible via /secrets/acv_key_file in the container
3) ACV_CA_FILE_SECRET - This is the CA certificate of the target ACVP server.  Available in libacvp directly, or can be fetch from the server with the openssl s_client utility
4) ACV_TOTP_SEED_SECRET - This is your time based one time password for accessing your ACVP server

There are several other env vars documented that need to be used for acvp_app.  They are set to the defaults for the acvp demo server in run_endpoint.sh
