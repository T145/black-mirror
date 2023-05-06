# https://github.com/google/sanitizers/wiki/AddressSanitizerComparisonOfMemoryTools
FROM golang:1.15 AS go1.15

WORKDIR "/src"

# https://github.com/johnkerl/miller/tree/v6.7.0
RUN git clone -b v6.7.0 https://github.com/johnkerl/miller.git .; \
    go install -v github.com/johnkerl/miller/cmd/mlr;

FROM golang:1.16 AS go1.16

# https://github.com/StevenBlack/ghosts#ghosts
RUN go install -v github.com/StevenBlack/ghosts@v0.2.2; \
    # https://github.com/ipinfo/cli#-ipinfo-cli
    go install -v github.com/ipinfo/cli/ipinfo@ipinfo-2.10.1;

FROM golang:1.20 AS go1.20

# https://github.com/mikefarah/yq/
RUN go install -v github.com/mikefarah/yq/v4@v4.33.3

# https://hub.docker.com/_/buildpack-deps/
FROM buildpack-deps:stable as utils

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
# https://www.gnu.org/software/parallel/checksums/
RUN curl http://pi.dk/3/ | bash \
    && find /usr/local/bin/ -type f ! -name 'par*' -delete

# https://wiki.debian.org/DiskFreeSpace
# https://raphaelhertzog.com/mastering-debian/
# https://gitlab.com/parrotsec/build/containers
FROM docker.io/parrotsec/core:base-lts-amd64
LABEL maintainer="T145" \
      version="5.8.2" \
      description="Runs the \"Black Mirror\" project! Check it out GitHub!" \
      org.opencontainers.image.description="https://github.com/T145/black-mirror#-docker-usage"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
STOPSIGNAL SIGKILL
WORKDIR "/root"

# https://github.com/ParrotSec/docker-images/blob/master/core/lts-amd64/Dockerfile#L6
# https://www.parrotsec.org/docs/apparmor.html
# rkhunter: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
COPY configs/etc/ /etc/
COPY --from=go1.15 /go/bin/ /usr/local/bin/
COPY --from=go1.16 /go/bin/ /usr/local/bin/
COPY --from=go1.20 /go/bin/ /usr/local/bin/
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
    apt-get -y install --no-install-recommends locales=2.31-13+deb11u6; \
    # https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    update-locale LANG=en_US.utf8;
# https://perldoc.perl.org/perllocale
ENV LANG=en_US.utf8 \
    # https://stackoverflow.com/questions/2499794/how-to-fix-a-locale-setting-warning-from-perl
    #LC_CTYPE=en_US.utf8 \
    #LANGUAGE=en_US.utf8 \
    # Make commands sort by the C locale
    LC_COLLATE=C \
    RESOLUTION_BIT_DEPTH=1600x900x16 \
    # https://nodejs.dev/en/learn/nodejs-the-difference-between-development-and-production/
    NODE_ENV=production

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
RUN apt-get -y upgrade; \
    apt-get -y install --no-install-recommends \
    #apt-show-versions # use dpkg -l (L) instead since ASV doesn't like GZ packages
    #apparmor=2.13.6-10 \
    #apparmor-utils=2.13.6-10 \
    aria2=1.35.0-3 \
    #auditd=1:3.0-2 \
    # For building and testing Perl 5.37.11
    build-essential=12.9 \
    csvkit=1.0.5-2 \
    curl=7.88.1-7~bpo11+2 \
    #debsums=3.0.2 \
    gawk=1:5.1.0-1 \
    git=1:2.39.2-1~bpo11+1 \
    grepcidr=2.0-2 \
    html-xml-utils=7.7-1.1 \
    #idn2=2.3.0-5 \
    jq=1.6-2.1 \
    # For building and testing IO::Socket::SSL
    libssl-dev=1.1.1n-0+deb11u4 \
    localepurge=0.7.3.10 \
    #moreutils=0.65-1 \
    #patch=2.7.6-7 \
    p7zip-full=16.02+dfsg-8 \
    #python3-pip=20.3.4-4+deb11u1 \
    #rkhunter=1.4.6-9 \
    symlinks=1.4-4 \
    unzip=6.0-26+deb11u1 \
    # For extracting *.xz archives
    xz-utils=5.2.5-2.1~deb11u1 \
    # For building and testing IO::Socket::SSL
    zlib1g-dev=1:1.2.11.dfsg-2+deb11u2; \
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

# Upgrade Perl
RUN curl -fLO https://www.cpan.org/src/5.0/perl-5.37.11.tar.xz; \
    echo '3946b00266595ccc44df28275e2fbb7b86c1482934cbeab2780db304a75ffd58 *perl-5.37.11.tar.xz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xaf perl-*.tar.xz; \
    #cat *.patch | patch -p1 # no included patch files at present
    ./Configure -Darchname=x86_64-linux-gnu -Duse64bitall -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local -Dusedevel -Dversiononly=undef -des; \
    make -j "$(nproc)"; \
    TEST_JOBS="$(nproc)" make test_harness; \
    make install; \
    rm -rf ./*; \
    # Install cpanm & the project packages
    curl -fLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7046.tar.gz; \
    echo '3e8c9d9b44a7348f9acc917163dbfc15bd5ea72501492cea3a35b346440ff862 *App-cpanminus-1.7046.tar.gz' | sha256sum --strict --check -; \
    tar --strip-components=1 -xaf App-cpanminus-*.tar.gz; \
    perl bin/cpanm .; \
    cpanm IO::Socket::SSL; \
    # Update cpm
    curl -fL https://raw.githubusercontent.com/skaji/cpm/0.997011/cpm -o /usr/local/bin/cpm; \
    # sha256 checksum is from docker-perl team, cf https://github.com/docker-library/official-images/pull/12612#issuecomment-1158288299
    echo '7dee2176a450a8be3a6b9b91dac603a0c3a7e807042626d3fe6c93d843f75610 */usr/local/bin/cpm' | sha256sum --strict --check -; \
    chmod +x /usr/local/bin/cpm; \
    # Cleanup
    rm -rf ./*; \
    # Install dependencies
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
    rmdir /run/mount 2>/dev/null || :;

#RUN pip3 install --no-cache-dir --upgrade snscrape==0.6.2.20230320; \
#    pip3 cache purge; \
#    py3clean -v ./usr/lib/python3.9 ./usr/share/python3; \
#    rm -rf /root/.cache;

ENTRYPOINT [ "bash" ]

# https://cisofy.com/lynis/controls/FILE-6310/
VOLUME [ "/home", "/tmp", "/var" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "command -v ipinfo && command -v ghosts && command -v parsort && command -v yq && command -v mlr" ]
