ARG GO_IMAGE=cgr.dev/chainguard/go:latest
ARG RUST_IMAGE=cgr.dev/chainguard/rust:latest-dev
ARG UTILS_IMAGE=cgr.dev/chainguard/wolfi-base:latest
ARG BASE_IMAGE=cgr.dev/chainguard/glibc-dynamic:latest-dev


FROM ${GO_IMAGE} AS golang

WORKDIR /src

RUN go install -v github.com/johnkerl/miller/v6/cmd/mlr@v6.15.0; \
    go install -v github.com/mikefarah/yq/v4@v4.46.1; \
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-3.3.1; \
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@v1.2.2; \
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@v2.8.0


FROM ${RUST_IMAGE} AS rust

# hadolint ignore=DL3002
USER root

RUN set -e; \
    apk add --no-cache build-base clang-19 libclang-cpp-19; \
    cargo install --locked --root /usr/local jaq; \
    cargo install --locked --root /usr/local ouch; \
    cargo install --locked --root /usr/local htmlq


FROM ${UTILS_IMAGE} AS utils

WORKDIR /root
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN set -e; \
    apk update; \
    apk add --no-cache bash build-base curl git ca-certificates findutils coreutils perl python3 gnutar xz \
        automake autoconf libtool pkgconf openssl-dev gnutls-dev c-ares-dev libpsl-dev zlib-dev \
        libssh2-dev sqlite-dev libxml2-dev; \
    rm -rf /var/cache/apk/*

# Install GNU parallel from its latest source (skip GPG verification for Docker builds)
# hadolint ignore=DL3003,DL4006
RUN set -e; \
    curl -fsSLO http://ftpmirror.gnu.org/parallel/parallel-latest.tar.bz2; \
    mkdir parallel-src; \
    tar -xf parallel-latest.tar.bz2 -C parallel-src --strip-components=1; \
    ( cd parallel-src; \
      ./configure; \
      make; \
      make install ); \
    rm -rf parallel-src parallel-latest.tar.bz2; \
    find /usr/local/bin/ -type f ! -name 'par*' -delete

# Install wget with c-ares and libpsl support
RUN set -e; \
    curl -fsSLO https://ftp.gnu.org/gnu/wget/wget-1.25.0.tar.gz; \
    tar --strip-components=1 -xzf wget-1.25.0.tar.gz; \
    ./configure --with-ssl=openssl --with-cares --with-libpsl; \
    make install; \
    rm -rf ./*

# Install pigz from its latest source (latest develop branch)
# https://github.com/madler/pigz
RUN set -e; \
    git config --global advice.detachedHead false; \
    git clone --depth 1 -b develop https://github.com/madler/pigz.git ./pigz-src; \
    make -C pigz-src; \
    install -m 0755 pigz-src/pigz /usr/local/bin/pigz; \
    rm -rf pigz-src

# Install aria2 from its latest release (1.37.0)
# https://github.com/aria2/aria2
# hadolint ignore=DL3003
RUN set -e; \
    curl -fsSLO https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz; \
    tar -xf aria2-1.37.0.tar.xz; \
    ( cd aria2-1.37.0; \
      ./configure --prefix=/usr/local --with-libcares --with-gnutls --without-openssl --with-libxml2 --with-libssh2 --with-sqlite3; \
      make; \
      make install ); \
    rm -rf aria2-1.37.0 aria2-1.37.0.tar.xz

# hadolint ignore=DL3003
RUN set -e; \
    curl -fsSLO https://www.pc-tools.net/files/unix/grepcidr-2.0.tar.gz; \
    tar -xf grepcidr-2.0.tar.gz; \
    ( cd grepcidr-2.0; \
      make; \
      make prefix=/usr/local install ); \
    rm -rf grepcidr-2.0 grepcidr-2.0.tar.gz

# hadolint ignore=DL3003,DL4006
RUN set -e; \
    curl -fsSLO https://invisible-island.net/datafiles/release/mawk.tar.gz; \
    mkdir mawk-src; \
    tar -xf mawk.tar.gz -C mawk-src --strip-components=1; \
    ( cd mawk-src; \
      ./configure; \
      make; \
      make install ); \
    rm -rf mawk-src mawk.tar.gz


# Use Chainguard's glibc-compatible runtime so legacy tooling that expects glibc keeps working.
# https://edu.chainguard.dev/chainguard/chainguard-images/reference/glibc-dynamic/
FROM ${BASE_IMAGE}

USER root
WORKDIR /root

LABEL maintainer="T145" \
      version="7.1.1" \
      description="Runs the \"Black Mirror\" project! Check it out GitHub!" \
      org.opencontainers.image.created="2025-11-01" \
      org.opencontainers.image.revision="7.1.1" \
      org.opencontainers.image.source="https://github.com/T145/black-mirror" \
      org.opencontainers.image.url="https://github.com/T145/black-mirror" \
      org.opencontainers.image.vendor="T145" \
      org.opencontainers.image.description="https://github.com/T145/black-mirror#-docker-usage" \
      org.opencontainers.image.title="Black Mirror" \
      org.opencontainers.image.licenses="MIT"

VOLUME [ "/home", "/tmp", "/var" ]
ENTRYPOINT [ "bash" ]

# Install the base CLI stack plus `patch`, which we use for local CPAN fixes; packages come from Wolfi.
# https://packages.wolfi.dev/os
# Wolfi is a rolling-release distribution when using the public version, so packages cannot be pinned.
RUN apk update; \
    apk add --no-cache bash ca-certificates curl coreutils findutils gnutar xz unzip zip gzip \
        shadow util-linux tzdata gettext openssl gnutls python3 py3-pip bc gawk git lynx nodejs npm whois \
        c-ares libssh2 sqlite-libs libxml2 glibc-locale-en libidn2 libunistring patch; \
    # Enable the OpenSSL legacy provider; some older tools may still require it for MD4/MD5.
    # https://github.com/aria2/aria2/issues/2143
    if [ -f /etc/ssl/openssl.cnf ]; then \
        sed -i 's/^[[:space:]]*#[[:space:]]*\(legacy = legacy_sect\)/\1/' /etc/ssl/openssl.cnf || true; \
        sed -i 's/^[[:space:]]*#[[:space:]]*\(\[legacy_sect\]\)/\1/' /etc/ssl/openssl.cnf || true; \
        if ! grep -q "^\[legacy_sect\]" /etc/ssl/openssl.cnf; then \
            printf "\n[legacy_sect]\nactivate = 1\n" >> /etc/ssl/openssl.cnf; \
        fi; \
        if ! grep -q "^legacy = legacy_sect" /etc/ssl/openssl.cnf; then \
            sed -i '/^\[provider_sect\]/a legacy = legacy_sect' /etc/ssl/openssl.cnf || true; \
        fi; \
    fi; \
    rm -rf /var/cache/apk/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Stage the minimal config set we still need and the bespoke patch bundle for Perl modules.
COPY docker/configs/etc/ /etc/
COPY docker/configs/root/ /root/
COPY docker/patches/ /tmp/docker-patches/
COPY --from=golang /root/go/bin/ /usr/local/bin/
COPY --from=rust /usr/local/bin/jaq /usr/local/bin/
COPY --from=rust /usr/local/bin/ouch /usr/local/bin/
COPY --from=rust /usr/local/bin/htmlq /usr/local/bin/
COPY --from=utils /usr/local/bin/ /usr/local/bin/

# Configure locales and default environment
RUN localedef -i en_US -c -f UTF-8 en_US.UTF-8 || true; \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

ENV LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US \
    LANG=en_US.UTF-8 \
    LC_COLLATE=C \
    RESOLUTION_BIT_DEPTH=1600x900x16 \
    NODE_ENV=production \
    LD_LIBRARY_PATH=/usr/local/lib \
    PERL5OPTS=-Mutf8

RUN python3 -m ensurepip --upgrade; \
    pip3 install --no-cache-dir --upgrade pip==24.3.1 setuptools==75.6.0 wheel==0.45.1; \
    pip3 install --no-cache-dir csvkit==2.0.2; \
    find /usr/local/lib -type d -name '__pycache__' -exec rm -rf {} +

RUN npm install -g @adguard/hostlist-compiler@1.0.39; \
    npm cache clean --force; \
    rm -rf /root/.npm

# https://github.com/Perl/docker-perl
WORKDIR /usr/src/perl
RUN apk add --no-cache --virtual .perl-build build-base curl gnutar xz perl-utils openssl-dev zlib-dev libxcrypt-dev \
        gdbm-dev libnsl-dev util-linux-dev; \
    curl -fsSLO https://cpan.metacpan.org/authors/id/E/EH/EHERMAN/perl-5.43.4.tar.gz; \
    echo '75676cc02c1d4d6f4577f7fd953e07ab5d06f71cf4201753ab6e2b0ddb5a4931  perl-5.43.4.tar.gz' | sha256sum -c -; \
    tar --strip-components=1 -xaf perl-5.43.4.tar.gz; \
    rm perl-5.43.4.tar.gz; \
    arch_name=$(gcc -dumpmachine); \
    arch_bits=$(getconf LONG_BIT); \
    arch_flag=$([ "${arch_bits}" = "64" ] && echo '-Duse64bitall' || echo '-Duse64bitint'); \
    ./Configure -Darchname="${arch_name}" "${arch_flag}" -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -Dusedevel -Dversiononly=undef -des; \
    make -j"$(nproc)"; \
    TEST_JOBS="$(nproc)" make test_harness || true; \
    make install; \
    apk del .perl-build

WORKDIR /usr/src
RUN apk add --no-cache --virtual .cpan-build build-base openssl-dev zlib-dev libxcrypt-dev libidn2-dev libunistring-dev
RUN curl -fsSLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7047.tar.gz; \
    echo '963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5  App-cpanminus-1.7047.tar.gz' | sha256sum -c -; \
    tar -xzf App-cpanminus-1.7047.tar.gz; \
    rm App-cpanminus-1.7047.tar.gz

WORKDIR /usr/src/App-cpanminus-1.7047
RUN perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' bin/cpanm; \
    perl -pi -E 's{try_lwp=>1}{try_lwp=>0}g' bin/cpanm; \
    perl bin/cpanm .

WORKDIR /usr/src
RUN curl -fLO 'https://www.cpan.org/authors/id/C/CH/CHRISN/Net-SSLeay-1.94.tar.gz'; \
    echo '9d7be8a56d1bedda05c425306cc504ba134307e0c09bda4a788c98744ebcd95d  Net-SSLeay-1.94.tar.gz' | sha256sum -c -; \
    cpanm --notest --from $PWD Net-SSLeay-1.94.tar.gz; \
    curl -fLO 'https://www.cpan.org/authors/id/S/SU/SULLR/IO-Socket-SSL-2.091.tar.gz'; \
    echo 'c5996e7335912a5c99e06bdb47ff39df309a857cbd8fd2627a021cefdb53cf54  IO-Socket-SSL-2.091.tar.gz' | sha256sum -c -; \
    SSL_CERT_DIR=/etc/ssl/certs cpanm --from $PWD IO-Socket-SSL-2.091.tar.gz; \
    curl -fL https://raw.githubusercontent.com/skaji/cpm/0.997017/cpm -o /usr/local/bin/cpm; \
    echo 'e3931a7d994c96f9c74b97d1b5b75a554fc4f06eadef1eca26ecc0bdcd1f2d11  /usr/local/bin/cpm' | sha256sum -c -; \
    chmod +x /usr/local/bin/cpm; \
    curl -fsSLO https://www.cpan.org/authors/id/C/CF/CFAERBER/Net-IDN-Encode-2.500.tar.gz; \
    tar -xzf Net-IDN-Encode-2.500.tar.gz; \
    # hadolint ignore=DL3003
    ( cd Net-IDN-Encode-2.500 || exit; \
      # Perl 5.43 removed the legacy `uvuni_to_utf8_flags` helper, so remap to `uvchr_to_utf8_flags`.
      # https://perldoc.perl.org/perlapi#uvchr_to_utf8_flags
      sed -i 's/\r$//' /tmp/docker-patches/net-idn-encode-uvchr.patch; \
      patch -p1 < /tmp/docker-patches/net-idn-encode-uvchr.patch; \
      cpanm --notest --installdeps .; \
      perl Build.PL; \
      ./Build; \
      ./Build test; \
      ./Build install ); \
    rm -rf Net-IDN-Encode-2.500 Net-IDN-Encode-2.500.tar.gz; \
    rm -fr /root/.cpanm /root/Net-SSLeay-1.94* /root/IO-Socket-SSL-2.091* /usr/src/perl /usr/src/App-cpanminus-1.7047* /tmp/*; \
    cpanm --version && cpm --version; \
    # Wolfi ships a slim Perl core, so we pull the runtime CPAN modules our blacklist scripts import.
    # https://metacpan.org/pod/Domain::PublicSuffix
    cpanm Regexp::Common Data::Validate::Domain Data::Validate::IP Net::Works::Network Domain::PublicSuffix Text::Trim; \
    apk del .cpan-build

WORKDIR /root

RUN find -P -O3 /var/log -depth -type f -print0 | xargs -0 -r truncate -s 0; \
    find -P -O3 /etc/ /usr/ -type d -empty -delete

RUN install -d -m 0700 /home/nonroot/.parallel && \
    cp /root/.parallel/will-cite /home/nonroot/.parallel/will-cite && \
    cp -r /root/.config /home/nonroot/.config && \
    chown -R nonroot:nonroot /home/nonroot/.parallel /home/nonroot/.config

USER nonroot
WORKDIR /home/nonroot

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD echo "Container is healthy" || exit 1
