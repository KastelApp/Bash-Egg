FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl software-properties-common locales git gnupg wget sudo lzma liblzma-dev libcurl4 libcurl4-openssl-dev zip unzip default-jre wget curl libtool build-essential make libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
    && adduser container \
    && apt update -y
    
# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Python 2 & 3
RUN apt -y install python python-pip python3 python3-pip golang

# Add the ScyllaDB public key
RUN curl -sSf get.scylladb.com/server | sudo bash -s -- --scylla-version 4.6.1

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
