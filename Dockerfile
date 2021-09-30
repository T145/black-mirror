FROM ubuntu:21.04

LABEL maintainer="T145" \
      version="1.0.4" \
      description="Custom Docker Image used to run Black Mirror."

# configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# use apt-get & apt-cache rather than apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
RUN apt-get -y update

# install apt-utils early so debconf doesn't delay package configuration
RUN apt-get -y install apt-utils

# upgrade with proper configurations
RUN apt-get -y upgrade

RUN apt-get -y install \
      # download utilities
      git \
      aria2 \
      # archive managers
      p7zip-full \
      # text processors
      gawk \
      jq \
      miller \
      moreutils \
      sed \
      ipcalc \
      # perl
      libtry-tiny-perl \
      libnet-libidn-perl \
      libnet-idn-encode-perl \
      # install go for projectdiscovery programs
      golang-go \
      # install java for saxon
      #openjdk-16-jre-headless
      default-jdk
RUN apt-get clean
# RUN pip3 install --user --upgrade git+https://github.com/twintproject/twint.git@origin/master#egg=twint
