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
      version="4.7.2" \
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
      && apt-get -y --no-install-recommends install apt-utils=2.4.7 \
      && apt-get -y upgrade \
      && apt-get install -y --no-install-recommends \
      apt-show-versions=0.22.13 \
      aria2=1.36.0-1 \
      bc=1.07.1-3build1 \
      curl=7.81.0-1ubuntu1.3 \
      debsums=3.0.2 \
      gawk=1:5.1.0-1build3 \
      git=1:2.34.1-1ubuntu1.4 \
      gpg=2.2.27-3ubuntu2.1 \
      gpg-agent=2.2.27-3ubuntu2.1 \
      gzip=1.10-4ubuntu4 \
      iprange=1.0.4+ds-2 \
      jq=1.6-2.1ubuntu3 \
      libdata-validate-domain-perl=0.10-1.1 \
      libdata-validate-ip-perl=0.30-1 \
      libnet-idn-encode-perl=2.500-2build1 \
      libnet-libidn-perl=0.12.ds-3build6 \
      libregexp-common-perl=2017060201-1 \
      libtext-trim-perl=1.04-1 \
      libtry-tiny-perl=0.31-1 \
      locales=2.35-0ubuntu3.1 \
      miller=6.0.0-1 \
      moreutils=0.66-1 \
      nano=6.2-1 \
      p7zip-full=16.02+dfsg-8 \
      pandoc=2.9.2.1-3ubuntu2 \
      preload=0.6.4-5 \
      sed=4.8-1ubuntu2 \
      software-properties-common=0.99.22.3 \
      && apt-get install -y --no-install-recommends --reinstall ca-certificates=* \
      && add-apt-repository ppa:deadsnakes/ppa \
      && apt-get install -y --no-install-recommends \
      python3.8=3.8.13-1+jammy1 \
      python3.8-distutils=3.8.13-1+jammy1 \
      python3-pip=22.0.2+dfsg-1 \
      && apt-add-repository ppa:fish-shell/release-3 \
      && apt-get install -y --no-install-recommends fish=3.5.1-1~jammy \
      && apt-get clean autoclean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
      && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

# configure python packages
ENV PATH=$PATH:/root/.local/bin
RUN python3.8 -m pip install --no-cache-dir --upgrade -e git+https://github.com/twintproject/twint.git@origin/master#egg=twint
#      && update-alternatives --install /usr/bin/python python /usr/bin/python3.8 10

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
HEALTHCHECK --retries=1 CMD ipinfo -h && dnsx --help && httpx --help && ghosts -h && twint -h && lychee --help && parsort --help && debsums -sa

# RUN useradd -ms /bin/bash garry
# USER garry
# WORKDIR /home/garry

# configure the fish shell environment
RUN ["fish", "--command", "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"]
#SHELL ["fish", "--command"]
#RUN chsh -s /usr/bin/fish
#ENV SHELL /usr/bin/fish
ENTRYPOINT ["fish"]
#CMD ["param1","param2"] # passes params to ENTRYPOINT
