FROM golang:1.16 AS go1.16

# https://github.com/StevenBlack/ghosts#ghosts
RUN go get github.com/StevenBlack/ghosts;

# https://github.com/google/sanitizers/wiki/AddressSanitizerComparisonOfMemoryTools
FROM golang:1.19 AS go1.19

WORKDIR "/src"

# https://github.com/johnkerl/miller
RUN git config --global advice.detachedHead false; \
    git clone --depth 1 -b v6.12.0 https://github.com/johnkerl/miller.git .; \
    go install -v github.com/johnkerl/miller/cmd/mlr;

FROM golang:1.21 AS go1.21

# https://github.com/mikefarah/yq/
RUN go install -v github.com/mikefarah/yq/v4@v4.43.1; \
    # https://github.com/ipinfo/cli
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-3.3.1; \
    # https://github.com/projectdiscovery/dnsx
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@v1.2.1;

FROM amd64/rust:bookworm AS rust

# https://github.com/01mf02/jaq
# https://github.com/jqlang/jq/issues/105#issuecomment-1113508938
RUN cargo install --locked jaq

# https://hub.docker.com/_/buildpack-deps/
FROM buildpack-deps:stable as utils

WORKDIR "/root"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
# https://www.gnu.org/software/parallel/checksums/
RUN curl -sSL http://pi.dk/3/ | bash \
    && find /usr/local/bin/ -type f ! -name 'par*' -delete

# Build Wget from source to enable c-ares support
RUN apt-get -yq update --no-allow-insecure-repositories; \
    # The latest libssl-dev is already included!
    apt-get -y install --no-install-recommends libc-ares-dev=* libpsl-dev=*; \
    apt-get -y clean; \
    wget -q https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz; \
    tar --strip-components=1 -xzf wget*.gz; \
    ./configure --with-ssl=openssl --with-cares --with-psl; \
    make install; \
    # Lessen the layer cache size
    rm -rf ./*; \
    rm -rf /var/lib/apt/lists/*;
# Executable will be under /usr/bin/local

# https://wiki.debian.org/DiskFreeSpace
# https://raphaelhertzog.com/mastering-debian/
# https://gitlab.com/parrotsec/build/containers/-/blob/latest/core/Dockerfile?ref_type=heads
# https://hub.docker.com/r/parrotsec/core
FROM docker.io/parrotsec/core:base-lts-amd64
LABEL maintainer="T145" \
      version="6.2.6" \
      description="Runs the \"Black Mirror\" project! Check it out GitHub!" \
      org.opencontainers.image.description="https://github.com/T145/black-mirror#-docker-usage"

# https://cisofy.com/lynis/controls/FILE-6310/
VOLUME [ "/home", "/tmp", "/var" ]
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
STOPSIGNAL SIGKILL

# https://github.com/ParrotSec/docker-images/blob/master/core/lts-amd64/Dockerfile#L6
# https://www.parrotsec.org/docs/apparmor.html
# rkhunter: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
COPY configs/etc/ /etc/
COPY --from=go1.16 /go/bin/ /usr/local/bin/
COPY --from=go1.19 /go/bin/ /usr/local/bin/
COPY --from=go1.21 /go/bin/ /usr/local/bin/
COPY --from=rust /usr/local/cargo/bin/jaq /usr/local/bin/
COPY --from=utils /usr/local/bin/ /usr/local/bin/

# https://github.com/JefferysDockers/ubu-lts/blob/master/Dockerfile#L26
RUN echo '#!/bin/sh' >/usr/sbin/policy-rc.d \
    && echo 'exit 101' >>/usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    # https://github.com/JefferysDockers/ubu-lts/blob/master/Dockerfile#L33
    && dpkg-divert --local --rename --add /sbin/initctl \
    && cp -a /usr/sbin/policy-rc.d /sbin/initctl \
    && sed -i 's/^exit.*/exit 0/' /sbin/initctl \
    # https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    # https://github.com/JefferysDockers/ubu-lts/blob/master/Dockerfile#L78
    && mkdir -p /run/systemd && echo 'docker' >/run/systemd/container \
    && echo 'alias jaq="jaq -r"' >> ~/.bashrc \
    && source ~/.bashrc

WORKDIR "/root"

# Use "en_US.UTF-8" as the default locale
# https://wiki.debian.org/Locale
RUN apt-get -yq update --no-allow-insecure-repositories; \
    apt-get -y install --no-install-recommends locales=*; \
    locale-gen; \
    # https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    update-locale LANG=en_US.UTF-8; \
    # Lessen the layer cache size
    rm -rf /var/lib/apt/lists/*;

# https://perldoc.perl.org/perllocale
# https://stackoverflow.com/questions/2499794/how-to-fix-a-locale-setting-warning-from-perl
ENV LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US \
    LANG=en_US.UTF-8 \
    # Make commands sort by the C locale
    LC_COLLATE=C \
    RESOLUTION_BIT_DEPTH=1600x900x16 \
    # https://nodejs.dev/en/learn/nodejs-the-difference-between-development-and-production/
    NODE_ENV=production \
    # Required for idn2 to run
    LD_LIBRARY_PATH=/usr/local/lib

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
# dpkg -l (L) to get versions
# Use "en_US.UTF-8" as the default locale
# https://wiki.debian.org/Locale
RUN apt-get -q update --no-allow-insecure-repositories; \
    apt-get -yqf upgrade; \
    apt-get -y install --no-install-recommends \
    aria2=1.36.0-1 \
    build-essential=12.9 \
    csvkit=1.0.7-1 \
    curl=7.88.1-10+deb12u5 \
    debsums=3.0.2.1 \
    gawk=1:5.2.1-2 \
    git=1:2.39.2-1.1 \
    grepcidr=2.0-2 \
    html-xml-utils=7.7-1.1 \
    libc-ares2=1.18.1-3 \
    libpsl5=0.21.2-1 \
    libssl3=3.0.11-1~deb12u2 \
    localepurge=* \
    lynx=2.9.0dev.12-1 \
    p7zip-full=16.02+dfsg-8 \
    symlinks=* \
    unzip=6.0-28 \
    whois=5.5.17 \
    xz-utils=5.4.1-0.2 \
    zlib1g=1:1.2.13.dfsg-1; \
    apt-get install -y --no-install-recommends --reinstall ca-certificates=*; \
    # https://askubuntu.com/questions/477974/how-to-remove-unnecessary-locales
    localepurge; \
    # https://linuxhandbook.com/find-broken-symlinks/
    symlinks -rd /; \
    apt-get -y purge --auto-remove localepurge symlinks; \
    apt-get -y clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    rm -f /var/cache/ldconfig/aux-cache;

# Install idn2 (requires iconv, so it needs to be installed locally)
RUN wget -q https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz; \
    tar --strip-components=1 -xzf libiconv*.gz; \
    ./configure; \
    make install; \
    rm -rf ./*; \
    wget -q https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.xz; \
    tar --strip-components=1 -xzf libunistring*.gz; \
    ./configure; \
    make install; \
    rm -rf ./*; \
    wget -q https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz; \
    tar --strip-components=1 -xzf libidn2*.gz; \
    ./configure; \
    make install; \
    rm -rf ./*;

# Upgrade Perl
# https://github.com/Perl/docker-perl/blob/master/5.039.009-main%2Cthreaded-bullseye/Dockerfile
RUN wget -q https://cpan.metacpan.org/authors/id/P/PE/PEVANS/perl-5.39.9.tar.gz; \
    echo 'c589d2e36cbb8db30fb73f661ef2c06ffe9c680f8ebe417169ec259b48ec2119 *perl-5.39.9.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xzf perl-*.tar.gz; \
    cat *.patch | patch -p1 || :; \
    ./Configure -Darchname=x86_64-linux-gn -Duse64bitall -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -Dusedevel -Dversiononly=undef -des; \
    make -j "$(nproc)"; \
    TEST_JOBS="$(nproc)" make test_harness; \
    make install; \
    rm -rf ./*; \
    # Install cpanm & the project packages
    wget -q https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7047.tar.gz; \
    echo '963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5 *App-cpanminus-1.7047.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xzf App-cpanminus-*.tar.gz; \
    perl bin/cpanm .; \
    cpanm IO::Socket::SSL; \
    # Update cpm
    wget -q -P /usr/local/bin/ https://raw.githubusercontent.com/skaji/cpm/0.997014/cpm; \
    # https://github.com/skaji/cpm/blob/main/Changes
    echo 'ee525f2493e36c6f688eddabaf53a51c4d3b2a4ebaa81576ac8b9f78ab57f4a1 */usr/local/bin/cpm' | sha256sum --strict --check -; \
    chmod +x /usr/local/bin/cpm; \
    rm -rf ./*; \
    # Install dependencies
    cpanm Regexp::Common; \
    cpanm Data::Validate::Domain; \
    cpanm Data::Validate::IP; \
    cpanm Net::CIDR; \
    cpanm Net::IDN::Encode; \
    cpanm Text::Trim; \
    cpanm Try::Tiny;

# https://cisofy.com/lynis/controls/HRDN-7222/
RUN chown 0:0 /usr/bin/as \
    && chown 0:0 /usr/share/gcc; \
    #rkhunter --update || :; \
    echo 'will cite' | parallel --citation || :; \
    # https://github.com/debuerreotype/debuerreotype/pull/32
    rmdir /run/mount 2>/dev/null || :; \
    # clear all logs
    find -P -O3 /var/log -depth -type f -print0 | xargs -0 truncate -s 0; \
    # remove all empty directories in etc and usr
    find -P -O3 /etc/ /usr/ -type d -empty -delete;

# Fixes: "docker: Error response from daemon: unable to find user admin: no matching entries in passwd file."
RUN adduser --disabled-password --gecos "" admin
USER admin

ENTRYPOINT [ "bash" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "command -v ipinfo && command -v ghosts && command -v parsort && command -v yq && command -v mlr" ]
