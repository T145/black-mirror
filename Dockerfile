FROM golang:1.17 AS go

# https://golang.org/doc/go-get-install-deprecation#what-to-use-instead
# the install paths are where "main.go" lives

# https://github.com/projectdiscovery/httpx#usage
# https://github.com/projectdiscovery/dnsx#usage
# https://github.com/ipinfo/cli#-ipinfo-cli
# https://github.com/StevenBlack/ghosts#ghosts
RUN go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest \
    && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
    && go install github.com/ipinfo/cli/ipinfo@latest \
    && go install github.com/StevenBlack/ghosts@latest

# https://hub.docker.com/_/ubuntu/
# alias: 22.04, jammy-20220801, jammy, latest, rolling
FROM ubuntu:jammy

LABEL maintainer="T145" \
      version="4.6.2" \
      description="Custom Docker Image used to run blacklist projects."

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# fullstop to avoid lingering connections, data leaks, etc.
STOPSIGNAL SIGKILL

# https://docs.docker.com/develop/develop-images/multistage-build/
# can apply --chmod=755 to set all directory permissions if needed
COPY --from=go /usr/local/go/ /usr/local/
COPY --from=go /go/ /go/

# set go env path
# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
# https://stackoverflow.com/questions/68693154/package-is-not-in-goroot
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin
RUN go env -w GO111MODULE=off

# just in case
ENV NODE_ENV=production LYCHEE_VERSION=v0.10.0

# suppress language-related updates from apt-get to increase download speeds and configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/00aptitude \
      && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://docs.docker.com/engine/reference/builder/#from
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
# https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
# install apt-utils early so debconf doesn't delay package configuration
RUN apt-get -y update \
      && apt-get -y --no-install-recommends install apt-utils \
      && apt-get -y upgrade \
      && apt-get install -y --no-install-recommends \
      aria2 bc build-essential curl debsums gawk git gpg gzip iprange jq \
      libdata-validate-domain-perl libdata-validate-ip-perl libnet-idn-encode-perl \
      libnet-libidn-perl libregexp-common-perl libtext-trim-perl libtry-tiny-perl \
      locales miller moreutils nano p7zip-full pandoc preload python3-dev python3-pip sed \
      && apt-get clean autoclean \
      && apt-get -y autoremove \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
      && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

# configure python packages
# https://github.com/twintproject/twint-docker/blob/master/dockerfiles/latest/Dockerfile#L17
# ARG TWINT_VERSION=v2.1.21
# could potentially fit this in an intermediate docker image
ENV PATH=$PATH:/root/.local/bin
#RUN pip3 install --no-cache-dir --upgrade -e git+https://github.com/twintproject/twint.git@v2.1.21#egg=twint
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# install lychee
# https://github.com/lycheeverse/lychee-action/blob/master/action.yml#L31=
RUN curl -LO "https://github.com/lycheeverse/lychee/releases/download/${LYCHEE_VERSION}/lychee-${LYCHEE_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
      && tar -xvzf lychee-*.tar.gz \
      && chmod 755 lychee \
      && mv lychee /usr/local/bin/lychee \
      && rm -f lychee-*.tar.gz

# install the parallel beta that includes parsort
# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
RUN curl -sSf https://raw.githubusercontent.com/T145/black-mirror/master/scripts/docker/parsort_install.bash | bash \
      && echo 'will cite' | parallel --citation || true \
      && rm -f parallel-*.tar.*

# --interval=DURATION (default: 30s)
# --timeout=DURATION (default: 30s)
# --start-period=DURATION (default: 0s)
# --retries=N (default: 3)
HEALTHCHECK --retries=1 CMD ipinfo -h && dnsx --help && httpx --help && ghosts -h && lychee --help && parsort --help && debsums -sa

# RUN useradd -ms /bin/bash garry
# USER garry
# WORKDIR /home/garry
