FROM ubuntu:20.04

LABEL maintainer="T145"
LABEL version="1.0.0"
LABEL description="This is custom Docker Image for Black Mirror."

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y aria2 jq gawk sed golang-go ipcalc libnet-libidn-perl libnet-idn-encode-perl miller moreutils openjdk-16-jre-headless
RUN apt clean
