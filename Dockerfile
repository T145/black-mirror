# use synk's recommended os version
FROM ubuntu:impish

LABEL maintainer="T145" \
      version="3.0.3" \
      description="Custom Docker Image used to run blacklist projects."

# suppress language-related updates from apt-get to increase download speeds
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/00aptitude

# configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# > use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
# > install apt-utils early so debconf doesn't delay package configuration
# > upgrade with proper configurations
RUN apt-get -y update \
&& apt-get -y install apt-utils \
&& apt-get -y upgrade

# set python env path
ENV PATH=$PATH:/root/.local/bin

# set go env path
# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

RUN apt-get -y install aria2 bc build-essential curl gawk git golang-go gpg grepcidr gzip idn2 jq libdata-validate-domain-perl libdata-validate-ip-perl libnet-idn-encode-perl libnet-libidn-perl libregexp-common-perl libtext-trim-perl libtry-tiny-perl lynx miller moreutils nano p7zip-full preload python3-pip sed \
&& apt-get clean \
&& apt-get -y autoremove

# install the parallel beta that includes parsort
# https://oletange.wordpress.com/2018/03/28/excuses-for-not-installing-gnu-parallel/
# https://git.savannah.gnu.org/cgit/parallel.git/tree/README
RUN curl -sSf https://raw.githubusercontent.com/T145/black-mirror/master/scripts/docker/parsort_install.bash | bash
RUN echo 'will cite' | parallel --citation || true

# install twint in base python, otherwise "pandas" will be perma-stuck building in pypy
RUN pip3 install Commitizen twint

# https://golang.org/doc/go-get-install-deprecation#what-to-use-instead
# the install paths are where "main.go" lives

# https://github.com/projectdiscovery/httpx#usage
RUN go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# https://github.com/projectdiscovery/dnsx#usage
RUN go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# https://github.com/projectdiscovery/mapcidr#usage
RUN go install github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest

# https://github.com/ipinfo/cli#-ipinfo-cli
RUN go install github.com/ipinfo/cli/ipinfo@latest

# https://github.com/StevenBlack/ghosts#ghosts
RUN go install github.com/StevenBlack/ghosts@latest
