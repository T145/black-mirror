# use synk's recommended os version
FROM ubuntu:impish-20211015

LABEL maintainer="T145" \
      version="3.0.2" \
      description="Custom Docker Image used to run blacklist projects."

RUN ls -la
