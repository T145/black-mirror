FROM golang:1.17 AS go

# https://golang.org/doc/go-get-install-deprecation#what-to-use-instead
# the install paths are where "main.go" lives

# https://github.com/projectdiscovery/dnsx#usage
RUN go install github.com/projectdiscovery/dnsx/cmd/dnsx@v1.1.0 \
    # https://github.com/projectdiscovery/httpx#usage
    && go install github.com/projectdiscovery/httpx/cmd/httpx@v1.2.4 \
    # https://github.com/ipinfo/cli#-ipinfo-cli
    && go install github.com/ipinfo/cli/ipinfo@ipinfo-2.9.0 \
    # https://github.com/StevenBlack/ghosts#ghosts
    && go install github.com/StevenBlack/ghosts@v0.2.2

# https://hub.docker.com/_/ubuntu/
# alias: 22.04, jammy-20220801, jammy, latest, rolling
FROM ubuntu:jammy as utils

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
    build-essential=12.9ubuntu3 \
    curl=7.81.0-1ubuntu1.3 \
    dirmngr=2.2.27-3ubuntu2.1 \
    gpg=2.2.27-3ubuntu2.1 \
    gpg-agent=2.2.27-3ubuntu2.1 \
    && apt-get install -y --no-install-recommends --reinstall ca-certificates=* \
    && rm -rf /var/lib/apt/lists/*

# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
# https://www.gnu.org/software/parallel/checksums/
RUN curl pi.dk/3/ -o install.sh \
    && sha1sum install.sh | grep 12345678883c667e01eed62f975ad28b6d50e22a \
    && md5sum install.sh | grep cc21b4c943fd03e93ae1ae49e28573c0 \
    && sha512sum install.sh | grep 79945d9d250b42a42067bb0099da012ec113b49a54e705f86d51e784ebced224fdff3f52ca588d64e75f603361bd543fd631f5922f87ceb2ab0341496df84a35 \
    && bash install.sh \
    && find /usr/local/bin/ -type f ! -name 'par*' -delete

ENV LYCHEE_VERSION=v0.10.0 PANDOC_VERSION=2.19.2

# https://github.com/lycheeverse/lychee-action/blob/master/action.yml#L39
RUN curl -sLO "https://github.com/lycheeverse/lychee/releases/download/${LYCHEE_VERSION}/lychee-${LYCHEE_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
    && tar -xvzf lychee-*.tar.gz -C /usr/local/bin/ \
    # https://github.com/jgm/pandoc/blob/master/INSTALL.md#linux
    # final pandoc install is ~80MB vs ~155MB via apt
    && curl -sLO "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" \
    && tar -xvzf pandoc-*.tar.gz --strip-components 1 -C /usr/local/ \
    && rm -f /usr/local/bin/pandoc-server

# https://wiki.debian.org/DiskFreeSpace
# https://raphaelhertzog.com/mastering-debian/
FROM docker.io/parrotsec/core:base-lts-amd64
LABEL maintainer="T145" \
      version="5.2.0" \
      description="Custom Docker Image used to run blacklist projects."

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
STOPSIGNAL SIGKILL
ENV LANG=en_US.utf8 RESOLUTION_BIT_DEPTH=1600x900x16 NODE_ENV=production

# https://github.com/ParrotSec/docker-images/blob/master/core/lts-amd64/Dockerfile#L6
# https://www.parrotsec.org/docs/apparmor.html
# rkhunter: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
COPY configs/etc/ /etc/
COPY --from=go /go/bin/ /usr/local/bin/
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

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
RUN apt-get -q -y update --no-allow-insecure-repositories \
    && apt-get -y upgrade --with-new-pkgs \
    && apt-get -y install --no-install-recommends \
    #apt-show-versions # use dpkg -l (L) instead since ASV doesn't like GZ packages
    aria2=1.35.0-3 \
    apparmor=2.13.6-10 \
    apparmor-utils=2.13.6-10 \
    auditd=1:3.0-2 \
    curl=7.84.0-2~bpo11+1 \
    debsums=3.0.2 \
    gawk=1:5.1.0-1 \
    git=1:2.34.1-1~bpo11+1 \
    iprange=1.0.4+ds-2 \
    jq=1.6-2.1 \
    libdata-validate-domain-perl=0.10-1.1 \
    libdata-validate-ip-perl=0.30-1 \
    libnet-idn-encode-perl=2.500-1+b2 \
    libnet-libidn-perl=0.12.ds-3+b3 \
    libregexp-common-perl=2017060201-1 \
    libtext-trim-perl=1.04-1 \
    libtry-tiny-perl=0.30-1 \
    localepurge=0.7.3.10 \
    locales=2.31-13+deb11u3 \
    miller=5.10.0-1 \
    moreutils=0.65-1 \
    p7zip-full=16.02+dfsg-8 \
    #pandoc=2.9.2.1-1+b1 \ # ~155MB binary!
    preload=0.6.4-5+b1 \
    python3-pip=20.3.4-4+deb11u1 \
    rkhunter=1.4.6-9 \
    symlinks=1.4-4 \
    && apt-get install -y --no-install-recommends --reinstall ca-certificates=* \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /var/cache/ldconfig/aux-cache \
    && find -P -O3 /var/log -depth -type f -print0 | xargs -0 truncate -s 0 \
    # https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    # https://askubuntu.com/questions/477974/how-to-remove-unnecessary-locales
    && localepurge \
    # https://linuxhandbook.com/find-broken-symlinks/
    && symlinks -rd / \
    && apt-get -y purge --auto-remove localepurge symlinks \
    && find -P -O3 /etc/ /usr/ -type d -empty -delete

# https://cisofy.com/lynis/controls/HRDN-7222/
RUN chown 0:0 /usr/bin/as \
    && chown 0:0 /usr/share/gcc; \
    #rkhunter --update || :; \
    echo 'will cite' | parallel --citation || :; \
    # https://github.com/debuerreotype/debuerreotype/pull/32
    rmdir /run/mount 2>/dev/null || :;

RUN python3 -m pip install --no-cache-dir --upgrade -e git+https://github.com/JustAnotherArchivist/snscrape.git#egg=snscrape; \
    python3 -m pip cache purge; \
    py3clean -v ./usr/lib/python3.9 ./usr/share/python3; \
    rm -rf /root/.cache;

ENTRYPOINT [ "bash" ]

# https://cisofy.com/lynis/controls/FILE-6310/
VOLUME [ "/home", "/tmp", "/var" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "ipinfo -h && dnsx --help && httpx --help && ghosts -h && lychee --help && parsort --help" ]
