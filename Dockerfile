# Set the image distro and version for base container.
FROM docker.io/alpine:3.16 as base

# Set the default Bitcoin-core version and add ability to be modified externally when building the image.
ARG BITCOIN_CORE_VERSION=22.0

# Set the desired operating system architecture
ARG ARCHITECTURE="x86_64"

RUN apk update && \
    apk --no-cache add wget && \
    wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz
ADD https://bitcoincore.org/bin/bitcoin-core-22.0/SHA256SUMS ./


FROM docker.io/alpine:3.16 as builder
# Set the default Bitcoin-core version and add ability to be modified externally when building the image.
ARG BITCOIN_CORE_VERSION=22.0
# Set the desired operating system architecture
ARG ARCHITECTURE="x86_64"
# Release Key from the main website
ARG RELASE_KEY=71A3B16735405025D447E8F274810B012346C9A6

COPY --from=base bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz ./bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz
COPY --from=base SHA256SUMS ./SHA256SUMS

# Set environment variables so the values are available for future running containers.
ARG GLIBC_VERSION=2.35-r0

RUN apk update && \
    apk --no-cache add wget gnupg && \
    wget -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    # Install the glib-c packages
    apk --no-cache add glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    apk --no-cache add glibc-i18n-${GLIBC_VERSION}.apk && \
    # Download Wladimir J. van der Laan’s releases key for version 11.0 or later
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${RELASE_KEY} && \
    # Verify the checksum is signed with Wladimir J. van der Laan’s releases key
    gpg --fingerprint $RELASE_KEY && \
    grep " bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz" SHA256SUMS | sha256sum -c && \
    mkdir /opt/bitcoin-core && \
    tar --strip-components=1 -xzf bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz -C /opt/bitcoin-core && \
    rm bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz

# For the final container we use Google's Distroless container
FROM gcr.io/distroless/static:nonroot as final

# Copy all the necessary files to run our service under distroless
COPY --from=builder /opt/bitcoin-core /opt/bitcoin-core
COPY --from=builder /usr/glibc-compat /usr/glibc-compat
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /lib/libc.musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1

WORKDIR "/opt/bitcoin-core"

# From now on execute as bitcoin user.
USER nonroot

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

# Using CMD since we are ignoring 
CMD ["/usr/glibc-compat/lib/ld-linux-x86-64.so.2", "/opt/bitcoin-core/bin/bitcoind", "-zmqpubrawblock=tcp://0.0.0.0:28332", "-zmqpubrawtx=tcp://0.0.0.0:28333"]