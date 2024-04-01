FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl software-properties-common locales git \
    && apt-get install -y default-jre \
    && apt-get install -y zip unzip \
    && apt-get -y install lzma liblzma-dev libcurl4 libcurl4-openssl-dev \
    && adduser container \
    && apt-get update 
    

RUN apt-get -y install gnupg wget
    
RUN curl -fsSL https://packages.redis.io/gpg |  gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" |  tee /etc/apt/sources.list.d/redis.list && \
    apt update && \
    apt install -y redis

RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc |  apt-key add - && \
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" |  tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt update && \
    apt install -y mongodb-org

# Grant sudo permissions to container user for commands
RUN apt-get update && \
    apt-get -y install sudo

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_current.x | bash - \
    && apt -y install nodejs \
    && apt -y install ffmpeg \
    && apt -y install make \
    && apt -y install build-essential \
    && apt -y install wget \ 
    && apt -y install curl \
    && apt -y install libtool

# RUN curl -fsSL https://bun.sh/install | bash

# Install basic software support
RUN apt-get update && \
    apt-get install -y software-properties-common
    
# Python 2 & 3
RUN apt -y install python python-pip python3 python3-pip

# Download Go 1.22.1
RUN curl -o go1.22.1.linux-amd64.tar.gz https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz

# Extract the downloaded archive
RUN tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz

# Set the Go environment variables
ENV GOROOT=/usr/local/go
ENV PATH=$GOROOT/bin:$PATH

RUN apt install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
