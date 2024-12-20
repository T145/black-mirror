# https://github.com/google/sanitizers/wiki/AddressSanitizerComparisonOfMemoryTools
FROM golang:1.21 AS golang

WORKDIR "/src"

# https://github.com/johnkerl/miller
RUN git config --global advice.detachedHead false; \
    git clone --depth 1 -b v6.13.0 https://github.com/johnkerl/miller.git .; \
    go install -v github.com/johnkerl/miller/cmd/mlr; \
    rm -rf ./*; \
    # https://github.com/mikefarah/yq/
    go install -v github.com/mikefarah/yq/v4@v4.44.5; \
    # https://github.com/ipinfo/cli
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-3.3.1; \
    # https://github.com/projectdiscovery/dnsx
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@v1.2.1; \
    # https://github.com/projectdiscovery/subfinder
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@v2.6.7;

FROM amd64/rust:bookworm AS rust

# https://github.com/01mf02/jaq
# https://github.com/jqlang/jq/issues/105#issuecomment-1113508938
RUN cargo install --locked jaq

# https://hub.docker.com/_/buildpack-deps/
FROM buildpack-deps:stable AS utils

WORKDIR "/root"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
# https://www.gnu.org/software/parallel/checksums/
RUN curl -sSL http://pi.dk/3/ | bash && find /usr/local/bin/ -type f ! -name 'par*' -delete;

RUN apt-get -yq update --no-allow-insecure-repositories; \
    # Build WGet from source to enable c-ares support
    # The latest libssl-dev is already included!
    apt-get -y install --no-install-recommends libc-ares-dev=* libpsl-dev=*; \
    apt-get -y clean; \
    wget -q https://ftp.gnu.org/gnu/wget/wget-1.25.0.tar.gz; \
    tar --strip-components=1 -xzf wget*.gz; \
    ./configure --with-ssl=openssl --with-cares --with-libpsl; \
    make install; \
    rm -rf ./*; \
    # Version available from apt is 2.6
    git config --global advice.detachedHead false; \
    git clone --depth 1 -b v2.8 https://github.com/madler/pigz.git ./test; \
    make -C test; \
    mv ./test/pigz /usr/local/bin; \
    rm -rf ./*; \
    rm -rf /var/lib/apt/lists/*;
# Executable will be under /usr/bin/local

# https://wiki.debian.org/DiskFreeSpace
# https://raphaelhertzog.com/mastering-debian/
# https://gitlab.com/parrotsec/build/containers/-/blob/latest/core/Dockerfile?ref_type=heads
# https://hub.docker.com/r/parrotsec/core
FROM docker.io/parrotsec/core:base-lts-amd64
LABEL maintainer="T145" \
      version="6.5.1" \
      description="Runs the \"Black Mirror\" project! Check it out GitHub!" \
      org.opencontainers.image.description="https://github.com/T145/black-mirror#-docker-usage"

# https://cisofy.com/lynis/controls/FILE-6310/
VOLUME [ "/home", "/tmp", "/var" ]
ENTRYPOINT [ "bash" ]
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#STOPSIGNAL SIGKILL

# https://github.com/ParrotSec/docker-images/blob/master/core/lts-amd64/Dockerfile#L6
# https://www.parrotsec.org/docs/apparmor.html
# rkhunter: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
COPY configs/etc/ /etc/
COPY configs/root/ /~/
COPY --from=golang /go/bin/ /usr/local/bin/
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
    && mkdir -p /run/systemd && echo 'docker' >/run/systemd/container

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
    LD_LIBRARY_PATH=/usr/local/lib \
    # https://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default/
    PERL5OPTS=-Mutf8

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
    bc=1.07.1-3+b1 \
    build-essential=12.9 \
    csvkit=1.0.7-1 \
    curl=7.88.1-10+deb12u7 \
    debsums=3.0.2.1 \
    dos2unix=7.4.3-1 \
    gawk=1:5.2.1-2 \
    git=1:2.39.5-0+deb12u1 \
    grepcidr=2.0-2 \
    html-xml-utils=7.7-1.1 \
    libc-ares2=1.18.1-3 \
    libpsl5=0.21.2-1 \
    libssl3=3.0.14-1~deb12u2 \
    localepurge=* \
    lynx=2.9.0dev.12-1 \
    nodejs=18.19.0+dfsg-6~deb12u2 \
    npm=9.2.0~ds1-1 \
    p7zip-full=16.02+dfsg-8 \
    symlinks=* \
    unzip=6.0-28 \
    whois=5.5.17 \
    xz-utils=5.4.1-0.2 \
    zlib1g=1:1.2.13.dfsg-1; \
    # https://github.com/AdguardTeam/HostlistCompiler
    npm i -g @adguard/hostlist-compiler; \
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
# RUN wget -q https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz; \
#     tar --strip-components=1 -xzf libiconv*.gz; \
#     ./configure; \
#     make install; \
#     rm -rf ./*; \
#     wget -q https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.xz; \
#     tar --strip-components=1 -xzf libunistring*.gz; \
#     ./configure; \
#     make install; \
#     rm -rf ./*; \
#     wget -q https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz; \
#     tar --strip-components=1 -xzf libidn2*.gz; \
#     ./configure; \
#     make install; \
#     rm -rf ./*;

# Upgrade Perl
# https://github.com/Perl/docker-perl
# Threaded Bookworm
RUN wget -q https://cpan.metacpan.org/authors/id/B/BO/BOOK/perl-5.41.3.tar.gz; \
    echo '7b9cd0f84a5350ea485ae6c57f3231d338f8a00c23f193db3964a60d38cf8850 *perl-5.41.3.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xzf perl-*.tar.gz; \
    cat *.patch | patch -p1 || :; \
    ./Configure -Darchname=x86_64-linux-gnu -Duse64bitall -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -Dusedevel -Dversiononly=undef -des; \
    make -j "$(nproc)"; \
    #TEST_JOBS="$(nproc)" make test_harness; \
    make install; \
    rm -rf ./*; \
    # Install cpanm & the project packages
    wget -q https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7047.tar.gz; \
    echo '963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5 *App-cpanminus-1.7047.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xzf App-cpanminus-*.tar.gz; \
    perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' bin/cpanm; \
    perl -pi -E 's{try_lwp=>1}{try_lwp=>0}g' bin/cpanm; \
    perl bin/cpanm .; \
    wget -q 'https://www.cpan.org/authors/id/C/CH/CHRISN/Net-SSLeay-1.94.tar.gz'; \
    echo '9d7be8a56d1bedda05c425306cc504ba134307e0c09bda4a788c98744ebcd95d *Net-SSLeay-1.94.tar.gz' | sha256sum --strict --check -; \
    cpanm --from $PWD Net-SSLeay-1.94.tar.gz; \
    wget -q 'https://www.cpan.org/authors/id/S/SU/SULLR/IO-Socket-SSL-2.085.tar.gz'; \
    echo '95b2f7c0628a7e246a159665fbf0620d0d7835e3a940f22d3fdd47c3aa799c2e *IO-Socket-SSL-2.085.tar.gz' | sha256sum --strict --check -; \
    SSL_CERT_DIR=/etc/ssl/certs cpanm --from $PWD IO-Socket-SSL-2.085.tar.gz; \
    wget -q -P /usr/local/bin/ https://raw.githubusercontent.com/skaji/cpm/0.997017/cpm; \
    # sha256 checksum is from docker-perl team, cf https://github.com/docker-library/official-images/pull/12612#issuecomment-1158288299
    echo 'e3931a7d994c96f9c74b97d1b5b75a554fc4f06eadef1eca26ecc0bdcd1f2d11 */usr/local/bin/cpm' | sha256sum --strict --check -; \
    chmod +x /usr/local/bin/cpm; \
    rm -rf ./*; \
    # Install dependencies
    cpanm Regexp::Common; \
    cpanm Data::Validate::Domain; \
    cpanm Data::Validate::IP; \
    cpanm Net::IDN::Encode; \
    cpanm Net::Works::Network; \
    cpanm Domain::PublicSuffix; \
    cpanm Text::Trim;

# https://cisofy.com/lynis/controls/HRDN-7222/
RUN chown 0:0 /usr/bin/as; \
    chown 0:0 /usr/share/gcc; \
    #rkhunter --update || :; \
    #echo 'will cite' | parallel --citation || :; \
    # https://github.com/debuerreotype/debuerreotype/pull/32
    rmdir /run/mount 2>/dev/null || :; \
    # clear all logs
    find -P -O3 /var/log -depth -type f -print0 | xargs -0 truncate -s 0; \
    # remove all empty directories in etc and usr
    find -P -O3 /etc/ /usr/ -type d -empty -delete;

# Fixes: "docker: Error response from daemon: unable to find user admin: no matching entries in passwd file."
RUN adduser --disabled-password --gecos "" admin
USER admin

HEALTHCHECK NONE
