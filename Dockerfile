FROM golang:1.16 AS go1.16

# https://github.com/StevenBlack/ghosts#ghosts
RUN go get github.com/StevenBlack/ghosts;

# https://github.com/google/sanitizers/wiki/AddressSanitizerComparisonOfMemoryTools
FROM golang:1.18 AS go1.18

WORKDIR "/src"

# https://github.com/johnkerl/miller#readme
RUN git config --global advice.detachedHead false; \
    git clone --depth 1 -b v6.9.0 https://github.com/johnkerl/miller.git .; \
    go install -v github.com/johnkerl/miller/cmd/mlr;

FROM golang:1.21 AS go1.21

# https://github.com/mikefarah/yq/
RUN go install -v github.com/mikefarah/yq/v4@v4.40.3; \
    # https://github.com/ipinfo/cli#-ipinfo-cli
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-3.2.0;

# https://hub.docker.com/_/buildpack-deps/
FROM buildpack-deps:stable as utils

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
# https://www.gnu.org/software/parallel/checksums/
RUN curl http://pi.dk/3/ | bash \
    && find /usr/local/bin/ -type f ! -name 'par*' -delete

# Build Wget from source to enable c-ares support
RUN apt-get -y update; \
    # The latest libssl-dev is already included!
    apt-get -y install --no-install-recommends libc-ares-dev libpsl-dev; \
    apt-get -y clean; \
    wget https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz; \
    tar -xzf wget-*.tar.gz; \
    cd wget-1.21.4; \
    ./configure --with-ssl=openssl --with-cares --with-psl; \
    make install;
# Executable will be under /usr/bin/local

# https://wiki.debian.org/DiskFreeSpace
# https://raphaelhertzog.com/mastering-debian/
# https://gitlab.com/parrotsec/build/containers
FROM docker.io/parrotsec/core:base-lts-amd64
LABEL maintainer="T145" \
      version="6.0.2" \
      description="Runs the \"Black Mirror\" project! Check it out GitHub!" \
      org.opencontainers.image.description="https://github.com/T145/black-mirror#-docker-usage"

WORKDIR "/root"
# https://cisofy.com/lynis/controls/FILE-6310/
VOLUME [ "/home", "/tmp", "/var" ]
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
STOPSIGNAL SIGKILL

# https://github.com/ParrotSec/docker-images/blob/master/core/lts-amd64/Dockerfile#L6
# https://www.parrotsec.org/docs/apparmor.html
# rkhunter: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
COPY configs/etc/ /etc/
COPY --from=go1.18 /go/bin/ /usr/local/bin/
COPY --from=go1.16 /go/bin/ /usr/local/bin/
COPY --from=go1.21 /go/bin/ /usr/local/bin/
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

# Make the "en_US.UTF-8" locale the default
RUN apt-get -yq update --no-allow-insecure-repositories; \
    apt-get -y install --no-install-recommends locales=2.36-9+deb12u2; \
    # https://wiki.debian.org/Locale
    locale-gen; \
    # https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    update-locale LANG=en_US.UTF-8; \
    export LC_ALL=C man;

# https://perldoc.perl.org/perllocale
ENV LANGUAGE=en_US \
    LANG=en_US.UTF-8 \
    # Make commands sort by the C locale
    LC_COLLATE=C \
    RESOLUTION_BIT_DEPTH=1600x900x16 \
    # https://nodejs.dev/en/learn/nodejs-the-difference-between-development-and-production/
    NODE_ENV=production

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
# dpkg --list to get versions
RUN apt-get -y install --no-install-recommends \
    aria2=1.36.0-1 \
    build-essential=12.9 \
    csvkit=1.0.7-1 \
    curl=7.88.1-10+deb12u3 \
    debsums=3.0.2.1 \
    gawk=1:5.2.1-2 \
    git=1:2.39.2-1.1 \
    grepcidr=2.0-2 \
    html-xml-utils=7.7-1.1 \
    jq=1.6-2.1 \
    libc-ares2=1.18.1-3 \
    libpsl5=0.21.2-1 \
    libssl3=3.0.11-1~deb12u1 \
    localepurge=* \
    p7zip-full=16.02+dfsg-8 \
    symlinks=* \
    unzip=6.0-28 \
    #wget=1.21.3-1+b2 \
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
    rm -f /var/cache/ldconfig/aux-cache; \
    # clear all logs
    find -P -O3 /var/log -depth -type f -print0 | xargs -0 truncate -s 0; \
    # remove all empty directories
    find -P -O3 /etc/ /usr/ -type d -empty -delete;

# https://cisofy.com/lynis/controls/HRDN-7222/
RUN chown 0:0 /usr/bin/as \
    && chown 0:0 /usr/share/gcc; \
    #rkhunter --update || :; \
    echo 'will cite' | parallel --citation || :; \
    # https://github.com/debuerreotype/debuerreotype/pull/32
    rmdir /run/mount 2>/dev/null || :;

# Upgrade Perl
# https://github.com/Perl/docker-perl/blob/master/5.039.005-main%2Cthreaded-bullseye/Dockerfile
RUN curl -fLO https://www.cpan.org/src/5.0/perl-5.39.2.tar.xz; \
    echo 'b7ae33d3c6ff80107d14c92dfb3d8d4944fec926b11bcc40c8764b73c710694f *perl-5.39.2.tar.xz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xaf perl-*.tar.xz; \
    #cat *.patch | patch -p1 || :; \
    ./Configure -Darchname=x86_64-linux-gnu -Duse64bitall -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -Dusedevel -Dversiononly=undef -des; \
    make -j "$(nproc)"; \
    TEST_JOBS="$(nproc)" make test_harness; \
    make install; \
    rm -rf ./*; \
    # Install cpanm & the project packages
    curl -fLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7047.tar.gz; \
    echo '963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5 *App-cpanminus-1.7047.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xaf App-cpanminus-*.tar.gz; \
    perl bin/cpanm .; \
    cpanm IO::Socket::SSL; \
    # Update cpm
    curl -fL https://raw.githubusercontent.com/skaji/cpm/0.997014/cpm -o /usr/local/bin/cpm; \
    # https://github.com/skaji/cpm/blob/main/Changes
    echo 'ee525f2493e36c6f688eddabaf53a51c4d3b2a4ebaa81576ac8b9f78ab57f4a1 */usr/local/bin/cpm' | sha256sum --strict --check -; \
    chmod +x /usr/local/bin/cpm; \
    # Cleanup
    rm -rf ./*; \
    # Install dependencies
    cpanm Regexp::Common; \
    cpanm Data::Validate::Domain; \
    cpanm Data::Validate::IP; \
    cpanm Net::CIDR; \
    cpanm Net::IDN::Encode; \
    cpanm Text::Trim; \
    cpanm Try::Tiny;

# To fix:
# docker: Error response from daemon: unable to find user admin: no matching entries in passwd file.
RUN useradd -m admin && echo "admin:headhoncho" | chpasswd
#&& usermod -aG wheel admin
USER admin

#RUN pip3 install --no-cache-dir --upgrade snscrape==0.6.2.20230320; \
#    pip3 cache purge; \
#    py3clean -v ./usr/lib/python3.9 ./usr/share/python3; \
#    rm -rf /root/.cache;

ENTRYPOINT [ "bash" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "command -v ipinfo && command -v ghosts && command -v parsort && command -v yq && command -v mlr" ]
