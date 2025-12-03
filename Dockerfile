From fedora:43 AS builder

# install needed tools
run sudo dnf install -y git perl-FindBin perl-IPC-Cmd gcc make \
                        perl-File-Compare perl-File-Copy perl-Time-Piece \
                        perl-Digest-SHA

# Start by building openssl, we deafult to the latest FIPS approved version
RUN git clone --depth 1 --branch openssl-3.5.4 https://github.com/openssl/openssl && \
    cd openssl && \
    ./Configure --prefix=/opt/openssl enable-fips no-docs && \
    make -j && \
    make install && \
    cd .. && rm -rf openssl



