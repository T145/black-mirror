# https://github.com/google/sanitizers/wiki/AddressSanitizerComparisonOfMemoryTools
FROM golang:1.24.5 AS golang

WORKDIR "/src"

# https://github.com/johnkerl/miller
RUN git config --global advice.detachedHead false; \
    git clone --depth 1 -b v6.14.0 https://github.com/johnkerl/miller.git .; \
    # https://github.com/johnkerl/miller?tab=readme-ov-file#building-from-source
    go install github.com/johnkerl/miller/v6/cmd/mlr; \
    rm -rf ./*; \
    # https://github.com/mikefarah/yq/
    go install -v github.com/mikefarah/yq/v4@v4.46.1; \
    # https://github.com/ipinfo/cli
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-3.3.1; \
    # https://github.com/projectdiscovery/dnsx
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@v1.2.2; \
    # https://github.com/projectdiscovery/subfinder
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@v2.8.0;

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
    git clone --depth 1 -b develop https://github.com/madler/pigz.git ./test; \
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
      version="6.6.1" \
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
    aria2=* \
    bc=* \
    build-essential=* \
    csvkit=* \
    curl=* \
    debsums=* \
    dos2unix=* \
    dpkg-dev=* \
    gawk=* \
    git=* \
    grepcidr=* \
    html-xml-utils=* \
    libc-ares2=* \
    libpsl5=* \
    libssl3=* \
    localepurge=* \
    lynx=* \
    nodejs=* \
    npm=* \
    p7zip-full=* \
    symlinks=* \
    unzip=* \
    whois=* \
    xz-utils=* \
    zlib1g=*; \
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
WORKDIR /usr/src/perl
RUN curl -fL https://cpan.metacpan.org/authors/id/B/BO/BOOK/perl-5.42.0.tar.gz -o perl-5.42.0.tar.gz; \
    echo 'e093ef184d7f9a1b9797e2465296f55510adb6dab8842b0c3ed53329663096dc *perl-5.42.0.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xaf perl-5.42.0.tar.gz -C /usr/src/perl; \
    rm perl-5.42.0.tar.gz; \
    cat *.patch | patch -p1 || : ; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    archBits="$(dpkg-architecture --query DEB_BUILD_ARCH_BITS)"; \
    archFlag="$([ "$archBits" = '64' ] && echo '-Duse64bitall' || echo '-Duse64bitint')"; \
    ./Configure -Darchname="$gnuArch" "$archFlag" -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -des; \
    make -j$(nproc); \
    make install; \
    cd /usr/src; \
    curl -fLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7047.tar.gz; \
    echo '963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5 *App-cpanminus-1.7047.tar.gz' | sha256sum --strict --check -; \
    tar -xzf App-cpanminus-1.7047.tar.gz && cd App-cpanminus-1.7047; \
    perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' bin/cpanm; \
    perl -pi -E 's{try_lwp=>1}{try_lwp=>0}g' bin/cpanm; \
    perl bin/cpanm . && cd /root; \
    curl -fL https://raw.githubusercontent.com/skaji/cpm/0.997017/cpm -o /usr/local/bin/cpm; \
    # sha256 checksum is from docker-perl team, cf https://github.com/docker-library/official-images/pull/12612#issuecomment-1158288299
    echo 'e3931a7d994c96f9c74b97d1b5b75a554fc4f06eadef1eca26ecc0bdcd1f2d11 */usr/local/bin/cpm' | sha256sum --strict --check -; \
    chmod +x /usr/local/bin/cpm; \
    rm -fr /root/.cpanm /usr/src/perl /usr/src/App-cpanminus-1.7047* /tmp/*; \
    cpanm --version && cpm --version; \
    # Install project dependencies
    cpanm Regexp::Common; \
    cpanm Data::Validate::Domain; \
    cpanm Data::Validate::IP; \
    cpanm Net::IDN::Encode; \
    cpanm Net::Works::Network; \
    cpanm Domain::PublicSuffix; \
    cpanm Text::Trim;

WORKDIR "/root"

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
