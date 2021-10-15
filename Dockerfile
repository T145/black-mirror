FROM ubuntu:21.04

LABEL maintainer="T145" \
      version="1.2.0" \
      description="Custom Docker Image used to run Black Mirror."

# suppress language-related updates from apt-get to increase download speeds
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/00aptitude

# configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
RUN apt-get -y update

# install apt-utils early so debconf doesn't delay package configuration
RUN apt-get -y install apt-utils

# upgrade with proper configurations
RUN apt-get -y upgrade

RUN apt-get -y install aria2 curl gawk git golang-go gpg gzip ipcalc jq libnet-idn-encode-perl libnet-libidn-perl libregexp-common-perl libtry-tiny-perl make miller moreutils p7zip-full preload python3-pip sed
RUN apt-get clean

ENV PATH=$PATH:/root/.local/bin
RUN pip3 install twint

# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# install project discovery utilities
# the get paths are where "main.go" lives
# https://github.com/projectdiscovery/httpx
# https://github.com/projectdiscovery/dnsx
# https://github.com/projectdiscovery/shuffledns
# https://github.com/projectdiscovery/proxify
# https://github.com/StevenBlack/ghosts
# https://github.com/ipinfo/cli#-ipinfo-cli
RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
RUN go get -v github.com/projectdiscovery/dnsx/cmd/dnsx
RUN GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
RUN GO111MODULE=on go get -v github.com/projectdiscovery/proxify/cmd/proxify
#RUN go get -v github.com/StevenBlack/ghosts
RUN go get -v github.com/ipinfo/cli/grepip

# install the parallel beta that includes parsort
RUN curl -s pi.dk/3/ -o install.sh
RUN bash install.sh && rm -f install.sh
RUN echo 'will cite' | parallel --citation || true
