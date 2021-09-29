FROM ubuntu:20.04

LABEL maintainer="T145" \
      version="1.0.0" \
      description="Custom Docker Image for Black Mirror."

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y git aria2 jq gawk sed golang-go ipcalc libnet-libidn-perl libnet-idn-encode-perl miller moreutils openjdk-16-jre-headless
RUN apt clean

RUN git clone https://github.com/T145/black-mirror.git
WORKDIR black-mirror
