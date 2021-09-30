FROM ubuntu:20.04

LABEL maintainer="T145" \
      version="1.0.4" \
      description="Custom Docker Image used to run Black Mirror."

# configure debconf to be non-interactive
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# use apt-get & apt-cache over apt: https://askubuntu.com/questions/990823/apt-gives-unstable-cli-interface-warning
RUN apt-get update -y

# install apt-utils so debconf doesn't delay package configuration
RUN apt-get install -y apt-utils

# upgrade with proper configurations
RUN apt-get upgrade -y

RUN apt-get install -y git aria2 jq gawk sed p7zip-full golang-go ipcalc libtry-tiny-perl libnet-libidn-perl libnet-idn-encode-perl miller moreutils openjdk-16-jre-headless
RUN apt-get clean
# RUN pip3 install --user --upgrade git+https://github.com/twintproject/twint.git@origin/master#egg=twint
