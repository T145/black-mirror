FROM ubuntu:21.04

LABEL maintainer="T145" \
      version="1.1.0" \
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
RUN apt-get -y install aria2 curl gpg

# install archive managers
RUN apt-get -y install bzip2 p7zip-full

# install text processors
RUN apt-get -y install gawk ipcalc jq miller moreutils sed

# install environment dependencies
RUN apt-get -y install make golang-go default-jre

# install perl libraries
RUN apt-get -y install libtry-tiny-perl libnet-libidn-perl libnet-idn-encode-perl libregexp-common-perl

RUN apt-get clean
# RUN pip3 install --user --upgrade git+https://github.com/twintproject/twint.git@origin/master#egg=twint
RUN curl -s pi.dk/3/ -o install.sh
RUN bash install.sh
RUN echo 'will cite' | parallel --citation || true
RUN rm -f install.sh