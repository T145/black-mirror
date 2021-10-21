FROM ubuntu:21.04

LABEL maintainer="T145" \
      version="2.0.0" \
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

RUN apt-get -y install aria2 build-essential curl gawk git golang-go grepcidr gpg gzip idn2 ipcalc jq libnet-idn-encode-perl libnet-libidn-perl libregexp-common-perl libtry-tiny-perl make miller moreutils p7zip-full preload prips python3-pip r-base sed
RUN apt-get clean

# install libarchive manually since libarchive-dev is at version 3.4.3
# https://github.com/libarchive/libarchive/wiki/BuildInstructions#using-configure-for-building-from-the-command-line-on-linux-freebsd-solaris-cygwin-aix-interix-mac-os-x-and-other-unix-like-systems
RUN aria2c https://github.com/libarchive/libarchive/releases/download/v3.5.2/libarchive-3.5.2.tar.gz
RUN tar xzf libarchive-3.5.2.tar.gz
RUN cd libarchive-3.5.2
RUN ./configure
RUN make
RUN make check
RUN make install
RUN cd ..
RUN rm libarchive-3.5.2.tar.gz

# install R libarchive bindings
# https://github.com/r-lib/archive
RUN echo 'install.packages("archive", repos="https://cloud.r-project.org/")' | R --vanilla

ENV PATH=$PATH:/root/.local/bin
RUN pip3 install twint

# https://www.digitalocean.com/community/tutorials/how-to-install-go-and-set-up-a-local-programming-environment-on-ubuntu-18-04
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# install project discovery utilities
# the get paths are where "main.go" lives
# https://github.com/projectdiscovery/dnsx
# https://github.com/ipinfo/cli#-ipinfo-cli
RUN go get -v github.com/projectdiscovery/dnsx/cmd/dnsx
RUN go get -v github.com/ipinfo/cli/ipinfo

# install the parallel beta that includes parsort
RUN curl -sSf pi.dk/3/ | bash
RUN echo 'will cite' | parallel --citation || true
