From fedora:43 AS builder

ARG OPENSSL_TAG=master
ARG CURL_TAG=curl-8_17_0
ARG LIBACVP_TAG=v2.3.0

# install needed tools
run sudo dnf install -y git perl-FindBin perl-IPC-Cmd gcc make \
                        perl-File-Compare perl-File-Copy perl-Time-Piece \
                        perl-Digest-SHA autoconf automake libtool libpsl-devel

env LD_RUN_PATH=/opt/openssl/lib64:/opt/curl/lib

# Start by building openssl, we deafult to the latest FIPS approved version
RUN git clone --depth 1 --branch ${OPENSSL_TAG} https://github.com/openssl/openssl && \
    cd openssl && \
    ./Configure --prefix=/opt/openssl enable-fips no-docs && \
    make -j && \
    make install && \
    cd .. && rm -rf openssl

# Now build curl
RUN git clone --depth 1 --branch ${CURL_TAG} https://github.com/curl/curl.git &&\
    cd curl && \
    autoreconf -fi && \
    ./configure --prefix=/opt/curl --disable-manual --disable-static --enable-hsts --enable-ipv6 \
                --disable-docs --enable-symbol-hiding --enable-threaded-resolver --without-zstd \
                --without-gssapi --with-ssl=/opt/openssl --with-ca-bundle=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem && \
    make -j && \
    make install && \
    cd .. && \
    rm -rf curl

#COPY acvp.nist.gov.crt /
#COPY Demo.key /
#COPY Demo.cer /

# Build libacvp
RUN git clone --depth 1 --branch ${LIBACVP_TAG} https://github.com/cisco/libacvp.git && \
    cd libacvp && \
    ./configure --prefix=/usr --enable-unit-tests --with-libcurl-dir=/opt/curl --with-ssl-dir=/opt/openssl && \
    make -j && \
#   ACV_API_CONTEXT=acvp/ ACV_URI_PREFIX=/acvp/v1/ ACV_CA_FILE=/acvp.nist.gov.crt ACV_KEY_FILE=/Demo.key ACV_CERT_FILE=/Demo.cer ACV_TOTP_SEED=gyqLPHsr2yT37XhfPO8KFIO6yUKrvRBkFZJoxDTs8RR5vpkqlbsCGyVHR9hqq11B ACV_PORT=443 ACV_SERVER=demo.acvts.nist.gov ./test/runtest -v && \
    make install && \
    cd .. && \ 
    rm -rf libacvp

# Now copy stuff to the real container that we release
From fedora:43

COPY --from=builder /opt/ /opt/
COPY --from=builder /usr/bin/acvp_app /usr/bin/acvp_app
COPY --from=builder /usr/lib64/libacvp* /usr/lib64

COPY run_endpoint.sh /
RUN chmod +x /run_endpoint.sh
# make sure all apps use our build libs
env LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/curl/lib
env OPENSSL_MODULES=/opt/openssl/lib64/ossl-modules
env OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf
env OPENSSL_CONF_INCLUDE=/opt/openssl/ssl/

ENTRYPOINT [ "/run_endpoint.sh" ]

