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

# install daemons that optimize performance in the background
# https://manpages.ubuntu.com/manpages/hirsute/en/man8/preload.8.html
RUN apt-get -y install preload

# install download utilities
RUN apt-get -y install aria2 curl git gpg

# install archive managers
RUN apt-get -y install file gzip p7zip-full

# install text processors
RUN apt-get -y install gawk ipcalc jq miller moreutils sed

# install perl libraries
RUN apt-get -y install libtry-tiny-perl libnet-libidn-perl libnet-idn-encode-perl libregexp-common-perl

# install environment dependencies
RUN apt-get -y install make golang-go default-jre python3-pip

RUN apt-get clean

# configure python programs
ENV PATH=$PATH:/root/.local/bin
RUN pip3 install twint

# update the path to make go executables accessible to the system
# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# install project discovery utilities
# https://github.com/projectdiscovery/httpx
# https://github.com/projectdiscovery/dnsx
# https://github.com/projectdiscovery/shuffledns
# https://github.com/projectdiscovery/proxify
# https://github.com/projectdiscovery/subfinder
RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
RUN go get -v github.com/projectdiscovery/dnsx/cmd/dnsx
RUN GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
RUN GO111MODULE=on go get -v github.com/projectdiscovery/proxify/cmd/proxify
# RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

RUN curl -s pi.dk/3/ -o install.sh
RUN bash install.sh && rm -f install.sh
RUN echo 'will cite' | parallel --citation || true