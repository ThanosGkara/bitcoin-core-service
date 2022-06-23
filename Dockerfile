# Set the image distro and version for builder container.
FROM docker.io/alpine:3.16 as base

# Set the default Bitcoin-core version and add ability to be modified externally when building the image.
ARG BITCOIN_CORE_VERSION=22.0

# Set the desired operating system architecture
ARG ARCHITECTURE="x86_64"

RUN apk update && \
    apk --no-cache add wget && \
    wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz

ADD https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/SHA256SUMS.asc ./
ADD https://bitcoincore.org/bin/bitcoin-core-22.0/SHA256SUMS ./


# FROM docker.io/frolvlad/alpine-glibc:alpine-3.16_glibc-2.35
FROM docker.io/alpine:3.16 as main

# Set the default Bitcoin-core version and add ability to be modified externally when building the image.
ARG BITCOIN_CORE_VERSION=22.0
# Set the desired operating system architecture
ARG ARCHITECTURE="x86_64"
# Release Key from the main website
ARG RELASE_KEY=71A3B16735405025D447E8F274810B012346C9A6

COPY --from=base bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz ./bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz
COPY --from=base SHA256SUMS.asc ./SHA256SUMS.asc
COPY --from=base SHA256SUMS ./SHA256SUMS

# Set environment variables so the values are available for future running containers.
ENV GLIBC_VERSION=2.35-r0
ENV LANG=C.UTF-8

RUN apk update && \
    apk --no-cache add wget gnupg && \
    # adduser -u 1001 -g 1001 --gecos '' --disabled-password bitcoin && \
    # chown -R bitcoin:bitcoin /home/bitcoin/ && \
    wget -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    # Install the glib-c packages
    apk --no-cache add glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    apk --no-cache add glibc-i18n-${GLIBC_VERSION}.apk && \
    # Cleanup (cleanup now to release mem)
    rm -rf glibc-${GLIBC_VERSION}.apk && \
    rm -rf glibc-bin-${GLIBC_VERSION}.apk && \
    rm -rf glibc-i18n-${GLIBC_VERSION}.apk && \
    (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true)  && \
    rm /var/cache/apk/* && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    # apk del glibc-i18n wget && \
    # Download Wladimir J. van der Laan’s releases key for version 11.0 or later
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${RELASE_KEY} && \
    # Verify the checksum is signed with Wladimir J. van der Laan’s releases key
    gpg --fingerprint $RELASE_KEY && \
    grep " bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz" SHA256SUMS | sha256sum -c && \
    mkdir /opt/bitcoin-core && \
    tar --strip-components=1 -xzf bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz -C /opt/bitcoin-core && \
    rm bitcoin-${BITCOIN_CORE_VERSION}-${ARCHITECTURE}-linux-gnu.tar.gz

FROM gcr.io/distroless/static:nonroot as final

COPY --from=main /opt/bitcoin-core /opt/bitcoin-core
COPY --from=main /usr/glibc-compat /usr/glibc-compat
COPY --from=main /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=main /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=main /lib/libc.musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1

# RUN mkdir /opt/bitcoin-core/.bitcoin

WORKDIR "/opt/bitcoin-core"

# From now on execute as bitcoin user.
# USER bitcoin

# Using CMD since we are ignoring modifiers
CMD ["/usr/glibc-compat/lib/ld-linux-x86-64.so.2", "/opt/bitcoin-core/bin/bitcoind"]