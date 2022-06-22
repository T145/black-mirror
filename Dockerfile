# use snyk's recommended os version
FROM ubuntu:impish

LABEL maintainer="T145" \
      version="3.3.0" \
      description="Custom Docker Image used to run blacklist projects."

# suppress language-related updates from apt-get to increase download speeds and configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/00aptitude \
      && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# set python env path
ENV PATH=$PATH:/root/.local/bin

# set go env path
# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# > use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
# > install apt-utils early so debconf doesn't delay package configuration
# > upgrade with proper configurations
# > perform security patches last
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://docs.docker.com/engine/reference/builder/#from
# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory#21530768
RUN apt-get -y update && apt-get -y install apt-utils && apt-get -y upgrade && apt-get install -y --no-install-recommends \
      aria2 bc build-essential curl gawk gcc git golang-go gpg grepcidr gzip idn2 jq libc6-dev libssl-dev \
      libdata-validate-domain-perl libdata-validate-ip-perl libnet-idn-encode-perl libnet-libidn-perl libregexp-common-perl libtext-trim-perl libtry-tiny-perl \
      lynx miller moreutils nano p7zip-full pandoc pkg-config preload python3-dev python3-pip sed \
      && apt-get clean autoclean \
      && apt-get -y autoremove \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install the parallel beta that includes parsort
# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
RUN curl -sSf https://raw.githubusercontent.com/T145/black-mirror/master/scripts/docker/parsort_install.bash | bash \
      && echo 'will cite' | parallel --citation || true

# install twint in base python, otherwise "pandas" will be perma-stuck building in pypy
RUN pip3 install --no-cache-dir --upgrade -e git+https://github.com/twintproject/twint.git@v2.1.21#egg=twint

# https://golang.org/doc/go-get-install-deprecation#what-to-use-instead
# the install paths are where "main.go" lives

# https://github.com/projectdiscovery/httpx#usage
# https://github.com/projectdiscovery/dnsx#usage
# https://github.com/ipinfo/cli#-ipinfo-cli
# https://github.com/StevenBlack/ghosts#ghosts
RUN go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest \
      && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
      && go install github.com/ipinfo/cli/ipinfo@latest
      # && go install github.com/StevenBlack/ghosts@latest

# https://github.com/lycheeverse/lychee#cargo=
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -y \
      && cargo install lychee
